
import SearchBar from './SearchBar';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import ParticlesBackground from "./ParticlesBackground"
const Home = () => {
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
}
 
export default Home;
