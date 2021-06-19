import React, { ReactNode, useEffect } from "react";
import { Route, useLocation } from "react-router-dom";
import { useDispatch } from "react-redux";
import { SetPizzaCrumbAction } from "../reducers/breadcrumbs";
import { pizzaRoutes } from "../utils";

export function AwareRoute({ children }: { children: ReactNode }) {
  const { pathname } = useLocation();
  const [root, ...paths] = pathname.split("/");
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(
      SetPizzaCrumbAction(
        paths.map((p) => {
          let locationLabel = p;
          if (pizzaRoutes.indexOf(p) > -1) {
            locationLabel = p.toUpperCase();
          }
          return { link: p, locationLabel: p };
        })
      )
    );
  }, [pathname]);

  return <Route>{children}</Route>;
}
