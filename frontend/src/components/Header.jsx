import React from "react";
import { HeaderLogoContainer, MainHeader } from "../styles/headerStyles";
import { LightspeedLogoURL } from "../assets/constants";

const Header = () => {
  return (
    <MainHeader>
      <HeaderLogoContainer>
        <img src={LightspeedLogoURL} alt="Lightspeed logo"></img>
        <h1>Project Lightspeed</h1>
      </HeaderLogoContainer>
    </MainHeader>
  );
};

export default Header;
