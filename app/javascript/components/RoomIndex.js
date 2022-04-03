import React, { useState } from "react"

const RoomIndex = () => {
  const [roomId, setRoomId] = useState('');

  function onSubmit(e) {
    e.preventDefault();
    window.location.href = `/room/${roomId}`;
  }

  return <form onSubmit={onSubmit}>
    <label htmlFor='room_id'>Room Id:</label>
    <input type='text' name='room_id' value={roomId} onChange={e => setRoomId(e.target.value)}/>
    <button type='submit'>Join</button>
  </form>
}
export default RoomIndex