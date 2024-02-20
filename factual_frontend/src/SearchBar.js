import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {Form, InputGroup, Button, Spinner, Container, Row, Col } from  'react-bootstrap'
import { Search } from 'react-bootstrap-icons';

const SearchBar = () => {
    const navigate = useNavigate();
    const [searchQuery, setSearchQuery] = useState('');
    const [loading, setLoading] = useState(false);
    let data = null;

    const csrfToken = document.cookie.replace(
      /(?:(?:^|.*;\s*)csrftoken\s*=\s*([^;]*).*$)|^.*$/,
      '$1'
    );

  

    const handleSearch = async (e) => {
      e.preventDefault();
      try{
        setLoading(true);
        const apiUrl = "http://127.0.0.1:8000/"
        

        const response = await fetch(apiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken,
          },
          body: JSON.stringify({ "text/URL": searchQuery }),
        });
        if (response.ok) {
 
          data = await response.json();
          navigate('/search-results',  { state: { searchResults: data } });
        } else {
          console.error('Error:', response.statusText);
        }
      }catch (error) {
        console.error('Error:', error.message);
      }finally {
        setLoading(false);
      }
    };
  if(loading){
    return(
      <div style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(0, 0, 0, 1)',
        color: 'white',
        zIndex: 1050,
      }}>
        <Container fluid id="loader-container">
          <Row>
            <Col className="d-flex justify-content-end">
              <h1 className='loadingHeading'>FACTUAL</h1>
            </Col>
            <Col id="loader-sceond-col">
              <div className ="loader"></div>
            </Col>
          </Row>
          <Row id="loader-sceond-row">
            <Col>
              <p className='loadingParagraph'>It may take a while.Don't worry, we have a lot to analyze</p>
            </Col>
          </Row>
        </Container>
      </div>
    );
  }
  return (
    <Form onSubmit={handleSearch} id="search-form">
      <InputGroup className="mb-2" id="search-form">
          <Form.Control
            id="search-form-control"
            size="lg"
            type="text"
            placeholder="Input URL or fact to check"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)} 
 
          />
          <Button
            id="search-button"
            variant="light"
            size="lg"
            type="submit"
            disabled={loading}   
          >
          {loading ? <Spinner animation="border" size="sm" /> : <Search />}
          </Button>
      </InputGroup>
    </Form>
  );
};

export default SearchBar;


