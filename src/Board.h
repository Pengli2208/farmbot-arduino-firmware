#ifndef _FARMBOT_BOARD_ID
  // Default to FARMDUINO_V14
  #define FARMDUINO_V14

#else

  #if _FARMBOT_BOARD_ID == 0
    #define RAMPS_V14
  #elif _FARMBOT_BOARD_ID == 1
    #define FARMDUINO_V10
  #elif _FARMBOT_BOARD_ID == 2
    #define FARMDUINO_V14
  #endif

#endif
