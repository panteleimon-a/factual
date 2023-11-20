// ParticlesBackground.js
import React, { useCallback } from 'react';
import Particles from 'react-tsparticles';
import { loadFull } from "tsparticles";


const ParticlesBackground = () => {
 
  const init = useCallback(async (engine) => {
    await loadFull(engine)
  }, []);

  return (
    <Particles 
      init={init}
      options={{
        background: {
            color: {
                value: '#000000',
            },
            opacity: 1,
        },
        fpsLimit: 60,
        fullScreen: {
          enable: true,
          zIndex: -1,
        },
        particles: {
            color: {
                value: '#ffffff',
            },
            links: {
              enable: true,
              distance: 100,
              color: '#ffffff',
              opacity: 0.7,
              width: 2,
              blink: true,
              consent: true,
              shadow: {
                  enable: true,
                  color:'#ffffff',
                  blur: 5,
              },
            },
            collisions: {
                enable: false,
            },
            move: {
              angle: {
                offset: 0,
                value: 25,
              },
                direction: "random",
                enable: true,
                outModes: {
                    default: "out",
                },
                random: false,
                speed: 1.0,
                straight: false,
            },
            number: {
                density: {
                    enable: true,
                    area: 1000,
                },
                value: 40,
            },
            opacity: {
              random: {
                enable: true,
                minimumValue: .1,
              },
                value: 0.5,
        
            },
            shape: {
                type: "links",
            },
            size: {
                value: { min: 1, max: 5 },
            },
            twinkle: {
              particles: {
                enable: true,
                frequency: .5,
                opacity: 1
              }
            },
            wobble: {
              distance: 3,
              enable: true,
              speed: {
                angle: 50,
                move: 10,
              }
            }
        },
        detectRetina: true,
    }}
    />
  )
};

export default ParticlesBackground;
