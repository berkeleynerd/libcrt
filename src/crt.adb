WITH Ada.Strings;           USE Ada.Strings;
WITH Ada.Strings.Fixed;     USE Ada.Strings.Fixed;
WITH Ada.Strings.Unbounded; USE Ada.Strings.Unbounded;
WITH Ada.Text_IO;           USE Ada.Text_IO;

WITH ansi;

PACKAGE BODY crt IS

   program_halted : EXCEPTION;

   FUNCTION set_scroll_region (x1 : Positive; y1 : Positive; x2 : Positive; y2 : Positive) RETURN String IS
      report_cursor_position : Unbounded_String;
   BEGIN

      report_cursor_position := To_Unbounded_String (ansi.control_preamble & "[" & Trim (Integer'image (y1), Left) & ";");
      report_cursor_position := To_Unbounded_String (To_String (report_cursor_position) & Trim (Integer'image (y2), Left) & ";");
      report_cursor_position := To_Unbounded_String (To_String (report_cursor_position) & Trim (Integer'image (x1), Left) & ";");
      report_cursor_position := To_Unbounded_String (To_String (report_cursor_position) & Trim (Integer'image (x2), Left) & "r");

      RETURN To_String (report_cursor_position);

   END set_scroll_region;

   --  Positions the cursor to given line and column Line 1 is the top line and column 1 is the left column
   FUNCTION set_cursor_position (line : Positive := 1; column : Positive := 1) RETURN String IS
      prefix     : CONSTANT String    := ansi.control_preamble & '[';
      separator  : CONSTANT Character := ';';
      terminator : CONSTANT Character := 'H';

      line_image   : String := Positive'image (line);
      column_image : String := Positive'image (column);
   BEGIN
      zero_fill_line :
      FOR index IN line_image'range LOOP
         EXIT zero_fill_line WHEN line_image (index) /= ' ';

         line_image (index) := '0';
      END LOOP zero_fill_line;

      zero_fill_column :
      FOR index IN column_image'range LOOP
         EXIT zero_fill_column WHEN column_image (index) /= ' ';

         column_image (index) := '0';
      END LOOP zero_fill_column;

      RETURN prefix & line_image & separator & column_image & terminator;
   END set_cursor_position;

   PROCEDURE gotoxy (x : Positive := 1; y : Positive := 1) IS
   BEGIN
      Put (set_cursor_position (y, x));
   END gotoxy;

   PROCEDURE set_screen (x1 : Positive; y1 : Positive; x2 : Positive; y2 : Positive) IS
   BEGIN
      Put (set_scroll_region (x1, y1, x2, y2));
   END set_screen;

   PROCEDURE clrscr IS
   BEGIN
      Put (ansi.clear_screen);
   END clrscr;

   PROCEDURE clear_to_eol IS
   BEGIN
      Put (ansi.clear_end_of_line);
   END clear_to_eol;

   PROCEDURE normal_text IS
   BEGIN
      Put (ansi.normal_mode);
   END normal_text;

   PROCEDURE inverse_text IS
   BEGIN
      Put (ansi.inverse_mode);
   END inverse_text;

   PROCEDURE insline IS
   BEGIN
      Put (ansi.insert_line);
   END insline;

   PROCEDURE delline IS
   BEGIN
      Put (ansi.delete_line);
   END delline;

   PROCEDURE write (s : String) IS
   BEGIN
      Put (s);
   END write;

   PROCEDURE write_line (s : String) IS
   BEGIN
      Put_Line (s);
   END write_line;

   PROCEDURE get_cursor_position (x, y : OUT Integer) IS
      more   : Boolean;
      inkey  : Character;
      cnt    : Integer          := 0;
      key    : Integer;
      buffer : Unbounded_String := To_Unbounded_String ("");

      row_start, row_end       : Integer := 0;
      column_start, column_end : Integer := 0;
   BEGIN

      Put (ansi.query_cursor_position);

      Get_Immediate (inkey);
      key := Character'pos (inkey);

      IF (inkey = Character'val (27)) THEN

         row_start := 2;

         LOOP
            Get_Immediate (inkey, more);
            EXIT WHEN (NOT more) OR (inkey = Character'val (0));
            cnt    := cnt + 1;
            buffer := To_Unbounded_String (To_String (buffer) & inkey);

            IF inkey = ';' THEN
               row_end      := cnt - 1;
               column_start := cnt + 1;
            END IF;

            IF inkey = 'R' THEN
               column_end := cnt - 1;
            END IF;

         END LOOP;

         IF cnt >= 5 THEN
            y := Integer'value (To_String (buffer) (row_start .. row_end));
            x := Integer'value (To_String (buffer) (column_start .. column_end));
         ELSE
            RAISE program_halted;
         END IF;

      END IF;

   END get_cursor_position;

   FUNCTION get_cursor_x RETURN Integer IS
      x, y : Integer;
   BEGIN
      get_cursor_position (x, y);
      RETURN x;
   END get_cursor_x;

   FUNCTION get_cursor_y RETURN Integer IS
      x, y : Integer;
   BEGIN
      get_cursor_position (x, y);
      RETURN y;
   END get_cursor_y;

END crt;
