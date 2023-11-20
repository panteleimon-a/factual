
//import './App.css';
import './Styles.css'
import { Route, Routes } from 'react-router-dom';

import Layout from './Layout';
import Home from './Home';
import SearchResults from './SearchResults';

// react-bootstrap imports bellow here
import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  return (
    <div className="App">
        <Routes>
            <Route path="/" element={<Layout />}>
              <Route index element={<Home />} />
              <Route path="search-results" element={<SearchResults />} />
           </Route>
        </Routes>
    </div>

  );
}

export default App;
