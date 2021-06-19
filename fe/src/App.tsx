import React from "react";

import "./App.css";
import "antd/dist/antd.css";
import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import { Provider } from "react-redux";
import { Layout, Menu } from "antd";
import store from "./reducers";
import LandingZone from "./views/Landing";
import PizzaCrumb from "./views/PizzaCrumb";
const { Header, Content, Footer } = Layout;

function App() {
  return (
    <Provider store={store}>
      <Router>
        <Layout
          className="layout"
          style={{ height: "100vh", display: "flex", flexDirection: "column" }}
        >
          <Header>
            <div className="logo" />
            <Menu theme="dark" mode="horizontal" defaultSelectedKeys={["2"]}>
              {new Array(5).fill(null).map((_, index) => {
                const key = index + 1;
                return <Menu.Item key={key}>{`nav ${key}`}</Menu.Item>;
              })}
            </Menu>
          </Header>
          <Content
            style={{
              padding: "0 50px",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <PizzaCrumb />
            <div
              style={{ display: "flex", flex: 1, height: "100%" }}
              className="site-layout-content"
            >
              <Switch>
                <Route path="/">
                  <LandingZone />
                </Route>
              </Switch>
            </div>
          </Content>
          <Footer style={{ textAlign: "center" }}>
            Mag's Pizza Store ©2021
          </Footer>
        </Layout>
        ,
      </Router>
    </Provider>
  );
}

export default App;
