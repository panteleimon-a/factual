import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import { Element, scroller } from 'react-scroll';
import ParticlesBackground from "./ParticlesBackground"
import { ArrowUp, ArrowDown } from 'react-bootstrap-icons';
import React, { useState, useEffect } from 'react';
import SearchBar from './SearchBar';
const Home = ({ isLoggedIn, setShowLoginModal, isBetaAuthenticated }) => {
    
    const scrollToSection = (sectionId) => {
      scroller.scrollTo(sectionId, {
        duration: 800,
        delay: 0,
        smooth: 'easeOutQuad',
      });
    };



    
    const [userLoggedIn, setUserLoggedIn] = useState(isLoggedIn);
    
    useEffect(() => {
      setUserLoggedIn(isLoggedIn);
    }, [isLoggedIn]);

    
    if(isBetaAuthenticated){
      return (
      <Container className="d-flex flex-column justify-content-center text-center align-items-center">
      <ParticlesBackground/>
      <Row>
        <h2 id="main-phrase">
          Easy fact checking on the go!
        </h2>
        <Col className='mt-5'>
          <SearchBar />               
        </Col>
      </Row>
      <Row id="slogans-row">
        <Col>
          <h4 id="slogans-id">New era on fact checking</h4>
        </Col>
        <Col>
          <h4 id="slogans-id">The go to tool for journalism</h4>
        </Col>
        <Col>
            <h4 id="slogans-id">Work smarter not harder</h4>
        </Col>
      </Row>
    </Container>
    );
    }else{
    return (
      <Container fluid>
        <ParticlesBackground />
        <div>
          <div>
            <Element name="section1" className="section1">
              <Col>
                <Row>
                  <h2>A new era on fact checking</h2>
                </Row>
                <Row>
                  {userLoggedIn === false ? (
                    <button id="waitlist" onClick={() => setShowLoginModal(true)}>
                    Join waitlist
                    </button>
                  ) : (
                    <button id="waitlist">
                      Already joined!
                    </button>
                  )}
                
                </Row>
                <Row id="seaction1Row">
                  <p>or scroll to learn more</p>
                </Row>
              </Col>
              <button id="scrollBtnDown" onClick={() => scrollToSection('section2')}>
                  <ArrowDown size={50}/>
                </button>
            </Element>
            <Element name="section2" className="section2">
              <Col>
                  <Row>
                    <h2>Our mission</h2>
                  </Row>
                  <Row id="seaction1Row">
                    <p>is to make the process of fact checking <br/> easier, faster and solid proof</p>
                  </Row>
                  <Row>
                  {userLoggedIn === false ? (
                    <button id="waitlist">
                    Join waitlist
                    </button>
                  ) : (
                    <button id="waitlist">
                      Already joined!
                    </button>
                  )}
                  </Row>
                </Col>
                <button id="scrollBtnUp" onClick={() => scrollToSection('section1')}>
                    <ArrowUp size={50}/>
                  </button>
                  <button id="scrollBtnDown" onClick={() => scrollToSection('section3')}>
                    <ArrowDown size={50}/>
                  </button>
            </Element>
            <Element name="section3" className="section3">
              <h2>Section 3</h2>
              <button id="scrollBtnUp" onClick={() => scrollToSection('section2')}>
                <ArrowUp size={50}/>
              </button>
            </Element>
          </div>
        </div>
      </Container>
      
      
 
    );
    }
}
 
export default Home;
