import React, { createContext, useContext, useEffect, useReducer } from "react";
import PropTypes from "prop-types";

export const SocketContext = createContext();

const socketReducer = (state, action) => {
  switch (action.type) {
    case "initSocket": {
      return {
        ...state,
        socket: new WebSocket(action.url),
        url: action.url,
      };
    }
    case "renewSocket": {
      let timeout = state.wsTimeoutDuration * 2;
      if (timeout > 10000) {
        timeout = 10000;
      }
      return {
        ...state,
        socket: new WebSocket(state.url),
        wsTimeoutDuration: timeout,
      };
    }
    case "updateTimeout": {
      return { ...state, connectTimeout: action.timeout };
    }
    case "clearTimeout": {
      clearTimeout(state.connectTimeout);
      return { ...state };
    }
    case "resetTimeoutDuration": {
      return { ...state, wsTimeoutDuration: 250 };
    }
    default: {
      return { ...state };
    }
  }
};

const initialState = {
  url: "",
  socket: null,
  wsTimeoutDuration: 250,
  connectTimeout: null,
};

const SocketProvider = ({ children }) => {
  const [state, dispatch] = useReducer(socketReducer, initialState);

  const { socket, wsTimeoutDuration } = state;

  useEffect(() => {
    // run once on first render
    (async () => {
      try {
        const response = await fetch("config.json");
        const data = await response.json();
        if (Object.prototype.hasOwnProperty.call(data, "wsUrl")) {
          dispatch({
            type: "initSocket",
            url: data.wsUrl,
          });
        } else {
          console.error("config.json is invalid");
        }
      } catch (e) {
        console.error(e.message);
      }
    })();
  }, []);

  useEffect(() => {
    if (!socket) return;

    socket.onopen = () => {
      dispatch({ type: "resetTimeout" });
      dispatch({ type: "resetTimeoutDuration" });
      console.log("Connected to websocket");
    };

    socket.onclose = (e) => {
      const { reason } = e;
      console.log(
        `Socket is closed. Reconnect will be attempted in ${Math.min(
          wsTimeoutDuration / 1000
        )} second. ${reason}`
      );

      const timeout = setTimeout(() => {
        //check if websocket instance is closed, if so renew connection
        if (!socket || socket.readyState === WebSocket.CLOSED) {
          dispatch({ type: "renewSocket" });
        }
      }, wsTimeoutDuration);

      dispatch({
        type: "updateTimeout",
        timeout,
      });
    };

    // err argument does not have any useful information about the error
    socket.onerror = () => {
      console.error(`Socket encountered error. Closing socket.`);
      socket.close();
    };
  }, [socket]);

  const value = {
    socket: state.socket,
  };

  return (
    <SocketContext.Provider value={value}>{children}</SocketContext.Provider>
  );
};

export const useSocket = () => {
  const context = useContext(SocketContext);

  if (!context) {
    throw new Error("useSocket must be nested in SocketProvider");
  }

  return context;
};

export default SocketProvider;

SocketProvider.propTypes = {
  children: PropTypes.object,
};
