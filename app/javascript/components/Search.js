import React, { useState } from "react"
import PropTypes from "prop-types"
const Search = ({ token } ) => {
  const [value, setValue] = useState('');
  const [tracks, setTracks] = useState([]);

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
            {tracks.map(({ name, artists, album: { images } }) => (
              <tr>
                <th><img src={images.find(({ height }) => height === 64).url} /></th>
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
