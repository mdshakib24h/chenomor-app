const http = require('http');
const { Server } = require('socket.io');

const server = http.createServer();
const io = new Server(server, { cors: { origin: "*" } });

// ইউজারদের ট্র্যাক রাখার জন্য লিস্ট
let onlineUsers = [];

io.on('connection', (socket) => {
  console.log('User connected: ' + socket.id);

  // ইউজার যখন নিজের ডিটেইলস সহ ম্যাচ খুঁজতে চাইবে
  socket.on('find-stranger', (userData) => {
    // userData-এর মধ্যে থাকবে: { gender, interestedIn }
    const { gender, interestedIn } = userData;

    // ওয়েটিং লিস্ট থেকে এমন কাউকে খোঁজা যে এই ইউজারের শর্তের সাথে মিলে যায়
    let partnerIndex = onlineUsers.findIndex(user => {
      const matchGender = user.interestedIn === 'Everyone' || user.interestedIn === gender;
      const myMatch = interestedIn === 'Everyone' || interestedIn === user.gender;
      return matchGender && myMatch && user.socketId !== socket.id;
    });

    if (partnerIndex !== -1) {
      // পার্টনার পাওয়া গেলে লিস্ট থেকে সরিয়ে রুম তৈরি করা
      const partner = onlineUsers.splice(partnerIndex, 1)[0];
      const roomName = 'room_' + socket.id + '_' + partner.socketId;

      socket.join(roomName);
      io.sockets.sockets.get(partner.socketId)?.join(roomName);

      // উভয়কে ম্যাচ সফল হওয়ার সিগন্যাল পাঠানো
      io.to(roomName).emit('matched', { room: roomName, host: socket.id });
    } else {
      // উপযুক্ত কাউকে না পেলে ওয়েটিং লিস্টে যুক্ত করা
      onlineUsers.push({
        socketId: socket.id,
        gender: gender,
        interestedIn: interestedIn
      });
    }
  });

  // WebRTC সিগন্যালিং (অফার, অ্যানসার ও আইস ক্যান্ডিডেট আদান-প্রদান)
  socket.on('signal', (data) => {
    socket.to(data.room).emit('signal', data);
  });

  // স্কিপ বা কল কেটে দিলে
  socket.on('skip-user', (room) => {
    io.to(room).emit('partner-disconnected');
    socket.leave(room);
  });

  // ডিসকানেক্ট হয়ে গেলে লিস্ট থেকে রিমুভ করা
  socket.on('disconnect', () => {
    onlineUsers = onlineUsers.filter(user => user.socketId !== socket.id);
    console.log('User disconnected: ' + socket.id);
  });
});

server.listen(3000, () => {
  console.log('Signaling server running with Gender/Age filter on port 3000');
});
