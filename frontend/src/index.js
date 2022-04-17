import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";
import SocketProvider from "./context/SocketContext";
import RTCProvider from "./context/RTCPeerContext";
import GlobalStyle from "./styles/globalStyles";

ReactDOM.render(
  <>
    <GlobalStyle />
    <SocketProvider>
      <RTCProvider>
        <App />
      </RTCProvider>
    </SocketProvider>
  </>,
  document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
