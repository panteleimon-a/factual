
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
                Approach the info you need.
              </h2>
              <Col className='mt-5'>
                <SearchBar />               
              </Col>
            </Row>
            <Row>
            <footer id="footer-phrase">
  <p>factual by Bonefide
  </p>
</footer>
              </Row>
          </Container>
    );
}
 
export default Home;
