import { Col, Row, Container, Card } from "react-bootstrap";
import { useLocation } from 'react-router-dom';
import SearchBar from "./SearchBar";

const SearchResults = ( ) => {
  const location = useLocation();
  const searchResults = location.state ? location.state.searchResults : null;
  console.log(searchResults);
  const sortedSearchResults = searchResults ? [...searchResults].sort((a, b) => {
    const matchA = typeof a["Match"] === 'string' ? parseFloat(a["Match"]) : a["Match"];
    const matchB = typeof b["Match"] === 'string' ? parseFloat(b["Match"]) : b["Match"];
  
    return matchB - matchA;
  }) : null;
  console.log(sortedSearchResults);
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
            {sortedSearchResults && sortedSearchResults.map((result, index) => ( 
                               
                    <Col key={index} sm={12} md={4} className="d-flex justify-content-center">
                        <Card>
                            <Card.Title>
                                <div className="custum-label">factual rating</div>
                                <Container fluid id="card-title-container" className="d-flex justify-content-center">
                                    {result && result["Match"] !== undefined ? (
                                        <div className="outer">

                                        <div className="orbit-wrapper"  style={{  "--rotation": `${parseFloat(result["Match"].replace('%', '')) * 3.6}deg`}}>
                                        <div className="dot" ></div>
                                        </div>
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
                            {result  ? ( 
                                <a href={result["URL"]}>
                                    {new URL(result["URL"]).hostname}
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
