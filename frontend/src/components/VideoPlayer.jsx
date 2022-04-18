import React, { useEffect, useRef } from "react";
import PropTypes from "prop-types";
import { VideoPosterURL } from "../assets/constants";
import { Video } from "../styles/videoPlayerStyles";

const VideoPlayer = ({ src }) => {
  const videoRef = useRef(null);

  useEffect(() => {
    if (src) {
      videoRef.current.srcObject = src;
      videoRef.current.play();
    }
  }, [src]);

  return (
    <Video
      ref={videoRef}
      playsInline
      autoPlay
      controls
      muted
      poster={VideoPosterURL}
    ></Video>
  );
};

export default VideoPlayer;

VideoPlayer.propTypes = {
  src: PropTypes.object,
};
