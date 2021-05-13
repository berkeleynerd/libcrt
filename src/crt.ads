PACKAGE crt IS

   PROCEDURE gotoxy (x : Positive := 1; y : Positive := 1);

   PROCEDURE set_screen (x1 : Positive; y1 : Positive; x2 : Positive; y2 : Positive);

   PROCEDURE clrscr;

   PROCEDURE clear_to_eol;

   PROCEDURE normal_text;

   PROCEDURE inverse_text;

   PROCEDURE insline;

   PROCEDURE delline;

   PROCEDURE write (s : String);

   PROCEDURE write_line (s : String);

   PROCEDURE get_cursor_position (x, y : OUT Integer);

   FUNCTION get_cursor_x RETURN Integer;

   FUNCTION get_cursor_y RETURN Integer;

END crt;
