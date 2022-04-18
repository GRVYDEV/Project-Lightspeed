import React from "react";
import {
  ChatContainer,
  ChatMain,
  ChatHeading,
  ChatBody,
} from "../styles/liveChatStyles";

const LiveChat = () => {
  return (
    <ChatContainer>
      <ChatMain>
        <ChatHeading>
          <h6>Live Chat Room</h6>
          <i className="fas fa-long-arrow-up arrow"></i>
        </ChatHeading>

        <ChatBody>
          <i className="fas fa-construction fa-3x"></i>
          <h4>Coming Soon!</h4>
        </ChatBody>
      </ChatMain>
    </ChatContainer>
  );
};

export default LiveChat;
