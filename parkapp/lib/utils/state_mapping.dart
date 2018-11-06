// This is for converting the states between the server and the client.
int stateMapping(int state) {
  switch(state) {
    case 4: return 3;
    case 5: return 4;
    case 6: return 0;
    default: return state;
  }
}