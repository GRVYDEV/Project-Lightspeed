import React, { createContext, useContext, useState } from "react";
import PropTypes from "prop-types";

export const RTCContext = createContext();

const RTCProvider = ({ children }) => {
  const [pc] = useState(new RTCPeerConnection());

  const value = {
    pc,
  };

  return <RTCContext.Provider value={value}>{children}</RTCContext.Provider>;
};

export const useRTC = () => {
  const context = useContext(RTCContext);

  if (!context) {
    throw new Error("useRTC must be nested in RTCProvider");
  }

  return context;
};

export default RTCProvider;

RTCProvider.propTypes = {
  children: PropTypes.object,
};
