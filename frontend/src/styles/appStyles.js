import styled from "styled-components";

export const MainContainer = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  margin: 2em;

  @media only screen and (max-width: 1024px) {
    margin: 1.5em 0;
    display: flex;
    flex-direction: column;
    justify-content: space-evenly;
  }
`;

export const VideoContainer = styled.div`
  display: flex;
  flex-direction: column;
  color: #fff;
  margin: 0 2.5em;

  @media only screen and (max-width: 1024px) {
    margin: 0.3em;
  }
`;
