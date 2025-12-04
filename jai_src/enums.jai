// jai_src/enums.jai

Hotkey_Modifier :: enum_flags {
    NONE      :: 0x0;
    CONTROL   :: 0x1;
    SHIFT     :: 0x2;
    ALT       :: 0x4;
    SUPER     :: 0x8; // (Windows key, Command key)
}

Key :: enum {
    A; B; C; D; E; F; G; H; I; J; K; L; M;
    N; O; P; Q; R; S; T; U; V; W; X; Y; Z;
    
    NUM_0; NUM_1; NUM_2; NUM_3; NUM_4;
    NUM_5; NUM_6; NUM_7; NUM_8; NUM_9;

    F1; F2; F3; F4; F5; F6; F7; F8; F9; F10; F11; F12;

    UP; DOWN; LEFT; RIGHT;
    
    SPACE;
    ENTER;
    ESCAPE;
    TAB;
}