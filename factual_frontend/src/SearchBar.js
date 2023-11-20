import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {Form, InputGroup, Button, Spinner } from  'react-bootstrap'
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

    const handleKeyPress = (e) => {
      // Triggered by pressing the enter key
      if (e.key === 13) {
        
        handleSearch();
      }
    };

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
            onInput={handleKeyPress}
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


