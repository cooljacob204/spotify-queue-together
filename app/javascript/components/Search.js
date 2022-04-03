import React, { useEffect, useState, useRef } from "react"
import PropTypes from "prop-types"
import { Container, Form, Row, Card, Button, Col } from 'react-bootstrap';

const Search = ({ token } ) => {
  const [value, setValue] = useState('');
  const [tracks, setTracks] = useState([]);
  const [currentlyPlayingPreview, setCurrentlyPlayingPreview] = useState(null);
  const requestController = useRef(new AbortController());
  const debounceTimeout = useRef(null);

  const handleFormSubmit = (e) => {
    e.preventDefault();

    const search = async () => {
      requestController.current.abort();

      const resp = await fetch(
        `https://api.spotify.com/v1/search?q=track:${value}&type=track,artist,album&market=US`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          signal: requestController.signal,
      });

      if (resp.ok) {
        const { tracks: { items } } = await resp.json();

        setTracks(items);
      }
    }

    if (debounceTimeout.current) {
      clearTimeout(debounceTimeout.current);
    }

    debounceTimeout.current = setTimeout(() => {
      search();
    }, 500)
  };

  if (!token) {
    return <>You must have a token</>
  }

  const handleCurrentlyPlayingChange = (preview_url) => {
    if (currentlyPlayingPreview === preview_url) {
      previousAudio.current.src = '';

      setCurrentlyPlayingPreview(null);
    } else {
      setCurrentlyPlayingPreview(preview_url);
    }
  };

  const previousAudio = useRef();

  useEffect(() => {
    if (previousAudio.current) {
      previousAudio.current.src = '';
    }

    if (currentlyPlayingPreview) {
      previousAudio.current = new Audio(currentlyPlayingPreview);

      previousAudio.current.play();
    }
  }, [currentlyPlayingPreview])

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const query = params.get('q');

    if (query) {
      setValue(query);
    }
  }, []);


  useEffect(() => {
    if (window.history.pushState) {
      const newurl = window.location.protocol + "//" + window.location.host + window.location.pathname + `?q=${value}`;

      window.history.pushState({ path:newurl }, '', newurl);
    }

    if (value) {
      handleFormSubmit({ preventDefault: () => null });
    } else {
      setTracks([]);
    }
  }, [value])

  const albumArt = (images) => {
    const art = images.find(({ height }) => height === 640);

    if (art) {
      return art.url;
    } else {
      return '';
    }
  };

  const artistNames = (artists) => (
    artists.reduce((acc, { name }) => acc += (name + ' '), '')
  );

  const handleQueueOnClick = (song) => {
    const queue = async () => {
      const csrf = document.querySelector('[name=csrf-token]').content;

      const resp = await fetch('/queued_songs', {
        method: 'POST',
        body: JSON.stringify({
          song
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-TOKEN': csrf,
        }
      })
    }

    queue();
  };

  return (
    <Container>
      <Row>
        <Form onSubmit={handleFormSubmit}>
          <Form.Group className="mb-3">
            <Form.Label>Search</Form.Label>
            <Form.Control
              type='text'
              name='query'
              value={value} onChange={e => setValue(e.target.value)}
            />
          </Form.Group>
        </Form>
      </Row>
      {tracks.length > 0 && (
        tracks.map(({ name, artists, preview_url, uri, album: { images } }, index) => (
          <Card key={name + preview_url + index + artistNames(artists)} className='mb-3'>
            <Card.Img src={albumArt(images)} />
            <Card.ImgOverlay className='playback-overlay'>
              {preview_url && (
                <button
                  className="playback-button"
                  onClick={() => { handleCurrentlyPlayingChange(preview_url) }}
                >
                  {currentlyPlayingPreview === preview_url ? '||' : '▶'}
                </button>
              )}
            </Card.ImgOverlay>
            <Card.Body>
              <Row>
                <Col>
                  <Card.Title>{name}</Card.Title>
                  <Card.Subtitle>
                    {artistNames(artists)}
                  </Card.Subtitle>
                </Col>
                <Col>
                </Col>
              </Row>
              <Button onClick={() => handleQueueOnClick({
                name: name,
                artists: artists,
                preview_url: preview_url,
                uri: uri,
                album: { images: images } 
              })}>
                Queue
              </Button>
            </Card.Body>
          </Card>
        ))
      )}
    </Container>
  )
}

Search.propTypes = {
  token: PropTypes.string
};
export default Search
