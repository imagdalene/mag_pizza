import React from "react";
import { Breadcrumb } from "antd";
import { useSelector } from "react-redux";
import { RootState } from "../reducers";
import { PizzaCrumb } from "../reducers/breadcrumbs";
import { Link } from "react-router-dom";

export default function PizzaCrumbs() {
  const [pizzaCrumbs]: [PizzaCrumb[]] = useSelector((state: RootState) => [
    state.pizzaCrumbs,
  ]);
  return (
    <Breadcrumb style={{ margin: "16px 0" }}>
      {pizzaCrumbs.map((crumb: PizzaCrumb) => (
        <Breadcrumb.Item>
          <Link to={crumb.link}></Link>
          {crumb.locationLabel}
        </Breadcrumb.Item>
      ))}
    </Breadcrumb>
  );
}
