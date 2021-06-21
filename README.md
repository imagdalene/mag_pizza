# Mag's Pizza Store

## IaC rollout

Mainly runs on AWS! Well, absolutely runs on aws
Run terraform apply on the all the files up to 03. Use your own tf vars!

## UI Rollout

After the IaC for ui_03 is run, go to directory fe and `npm run build`
then `aws s3 cp build s3://<bucketname> --recursive`. That will dump the ui package to the FE bucket for serving via Cloudfront

## BE Workload rollout

1. First run `npm i`
1. Don't forget to `export REPO_URL=<your ecr url>`
1. Then run `npm run docker:build`
1. Then run `npm run docker:push`. The image is now in ECR
1. **Now** rollout the workload infra (workload_04) with `SHA=$(git rev-parse --short HEAD) ; tf apply -auto-approve -var "ImageHash=$REPO_URL:$SHA"` . Super crude but it works
