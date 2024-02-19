import { Col, Row, Container, Card } from "react-bootstrap";
import { useLocation } from 'react-router-dom';
import SearchBar from "./SearchBar";

const SearchResults = ( ) => {
  const location = useLocation();
  const searchResults = location.state ? location.state.searchResults : null;
  
  return (
    <div>
        <Container fluid>
            <Row className="mt-5 justify-content-center">
                <Col sm={6}>
                    <SearchBar />
                </Col>
            </Row>
            <Row className="mt-5">
                <h2>Results</h2>
            </Row>
            <Row className="mt-4">
            {searchResults && searchResults.map((result, index) => (                    
                    <Col key={index} sm={12} md={4} className="d-flex justify-content-center">
                        <Card>
                            <Card.Title>
                                <div className="custum-label">Match</div>
                                <Container fluid id="card-title-container" className="d-flex justify-content-center">
                                    {result && result["Match"] !== undefined ? (
                                        <div className="outer">
                                        <div className="dot" style={{ "--value": `calc(${result["Match"]} )` }}></div>
                                        <div className="inner">
                                          <p id="progresbar-rating">{result["Match"]}</p>
                                        </div>
                                      </div>
                                    ) : (
                                        <p>No Factual Index available for this result</p>
                                    )}

                                </Container>
                            </Card.Title>
                        <Card.Body>
                            <h4>Source:</h4>
                            {result && result.sources ? ( 
                                <a href={result.sources}>
                                    {new URL(result.sources).hostname}
                                </a>
                            ) : (
                            <p>No text available for this result</p>
                            )}
                        </Card.Body>
                        </Card>
                    </Col>
                ))}
            </Row>
        </Container>      
    </div>
  );
};

export default SearchResults;
