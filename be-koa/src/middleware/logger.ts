import { randomBytes } from 'crypto';
import { hrtime } from 'process';
import chalk from 'chalk';
import { Context, Next } from 'koa';

import { createLogger, format, Logger, transports } from 'winston';
import { Format } from 'logform';

const config = {
  logLevel: process.env.LOG_LEVEL || 'info',
}
/**
 * Returns black or white foreground text based on given background color for maximum contrast.
 * The algorithm is based on W3C Techniques for Accessibility Evaluation and Repair Tools working
 * draft.
 *
 * @see {@link http://www.w3.org/TR/AERT#color-contrast Techniques For Accessibility Evaluation And Repair Tools}
 * @param {string|number} bgColor
 */
const textColor = (bgColor: string | number): string => {
  const colorBytes = typeof bgColor === 'string' ? parseInt(`0x${bgColor}`) : bgColor;
  const red = colorBytes >> 16;
  const green = (colorBytes >> 8) & 0x00ff;
  const blue = colorBytes & 0x0000ff;
  const o = Math.round((red * 299 + green * 587 + blue * 114) / 1000);
  return o > 125 ? '#000000' : '#FFFFFF';
};

function getFormat(): Format {
  const formats = [
    format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss.SSSZZ',
    }),
    format.printf(({ level, timestamp, message, id }) => {
      if (id) {
        const coloredId = chalk.bgHex(id).hex(textColor(id))(id);
        return `${level} ${timestamp} — ${coloredId} ${message}`;
      } else {
        return `${level} ${timestamp} — ${message}`;
      }
    }),
  ];

  // If TTY supports color mode, add color support.
  if (chalk.supportsColor) {
    formats.unshift(format.colorize());
  }

  return format.combine(...formats);
}

export const logger: Logger = createLogger({
  level: config.logLevel,
  transports: [
    new transports.Console({
      format: getFormat(),
    }),
  ],
});


const coloredStatus = (status: number): string => {
  if (status < 400) {
    return chalk.green(status.toString());
  }

  if (status < 500) {
    return chalk.yellow(status.toString());
  }

  return chalk.red(status.toString());
};

const fileSize = (size: number): { size: number; unit: string } => {
  size = size || 0;

  // Kilobytes
  if (size >= 1024 && size < 1048576) {
    return { size: size / 1024, unit: 'K' };
  }

  // Megabytes
  if (size >= 1048576 && size < 1073741824) {
    return { size: size / 1048576, unit: 'M' };
  }

  // Gigabytes
  if (size >= 1073741824) {
    return { size: size / 1073741824, unit: 'G' };
  }

  return { size, unit: 'B' };
};

const middleware = async (ctx: Context, next: Next): Promise<void> => {
  ctx.id = randomBytes(3)
    .toString('hex')
    .slice(0, 6)
    .toUpperCase();
  const reqStart = hrtime();

  logger.log({
    level: 'info',
    id: ctx.id,
    message: chalk`{yellow ${ctx.request.method}} ${ctx.request.url}`,
  });

  await next();

  const [, reqDurationNano] = hrtime(reqStart);
  const status = coloredStatus(ctx.response.status);
  const { size, unit } = fileSize(ctx.response.length);
  const contentType = ctx.response.type;
  const elapsed = (reqDurationNano / 1000000).toFixed(1);

  logger.log({
    level: 'info',
    id: ctx.id,
    message: `${status} ${size.toLocaleString()}${unit} ${contentType} ${elapsed}ms`,
  });
};

export default middleware;
