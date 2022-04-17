import styled from "styled-components";

export const MainHeader = styled.header`
  background: #1f2128;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  border: 0.5px solid rgba(240, 243, 246, 0.1);
  padding: 1em;
`;

export const HeaderLogoContainer = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;

  h1 {
    font-weight: 600;
    font-size: 2em;
    color: white;
  }

  img {
    height: 90px;
    margin: auto;
  }
`;
