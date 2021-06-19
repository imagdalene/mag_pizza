import React from "react";
import { Link } from "react-router-dom";

export default function LandingZone() {
  return (
    <div
      style={{
        flex: 1,
        display: "flex",
        justifyContent: "center",

        alignItems: "center",
        backgroundImage:
          'url("https://images.unsplash.com/photo-1458642849426-cfb724f15ef7")',
      }}
    >
      <div
        style={{
          width: "50%",
          backgroundColor: "white",
          opacity: 0.9,
          display: "flex",
          alignItems: "center",
          padding: "35px",
          borderRadius: "5px",
          justifyContent: "center",
        }}
      >
        <Link to="/order"> Get Started On Your Pizza </Link>
      </div>
    </div>
  );
}
