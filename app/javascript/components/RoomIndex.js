import React, { useState } from "react"

const RoomIndex = () => {
  const [roomId, setRoomId] = useState('');

  function onSubmit(e) {
    e.preventDefault();
    window.location.href = `/room/${roomId}`;
  }

  return <div>
    <form onSubmit={onSubmit}>
      <label htmlFor='room_id'>Room Id:</label>
      <input type='text' name='room_id' value={roomId} onChange={e => setRoomId(e.target.value)}/>
      <button type='submit'>Join</button>
    </form>

    <form method="post">
      <button type='submit'>Create Room</button>
    </form>
  </div>
}
export default RoomIndex