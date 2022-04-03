import React, { useEffect, useState, useRef } from "react"
import PropTypes from "prop-types"
import { Binding } from "@babel/traverse";
const Search = ({ token } ) => {
  const [value, setValue] = useState('');
  const [tracks, setTracks] = useState([]);
  const [currentlyPlayingPreview, setCurrentlyPlayingPreview] = useState(null);

  const handleFormSubmit = (e) => {
    e.preventDefault();

    const search = async () => {
      const resp = await fetch(
        `https://api.spotify.com/v1/search?q=track:${value}&type=track,artist,album&market=US`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
      });

      if (resp.ok) {
        const { tracks: { items } } = await resp.json();

        setTracks(items);
      }
    }

    search();
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
  }

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

  return (
    <>
      <form onSubmit={handleFormSubmit}>
        <label htmlFor='query'>Search</label>
        <input
          type='text'
          name='query'
          value={value} onChange={e => setValue(e.target.value)}
        />
        <button type='submit'>Submit</button>
      </form>
      {tracks.length > 0 && (
        <table>
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Artist</th>
            </tr>
          </thead>
          <tbody>
            {tracks.map(({ name, artists, preview_url, album: { images } }) => (
              <tr key={preview_url}>
                <th className='album-art'>
                  <img src={images.find(({ height }) => height === 64).url} />
                  <button
                    className="btn"
                    onClick={() => { handleCurrentlyPlayingChange(preview_url) }}
                  >
                    {currentlyPlayingPreview === preview_url ? '||' : '▶'}
                  </button>
                </th>
                <th>{name}</th>
                <th>{artists.reduce((acc, { name }) => acc += (name + ' '), '')}</th>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  )
}

Search.propTypes = {
  token: PropTypes.string
};
export default Search
