(* ported version of Minos to work with the ARM backend of the Fox Compiler Suite *)
MODULE Tools;

IMPORT OFS, Device, SerialLog, Kernel, Platform;

CONST
	PacketSize 	= 8;
	MAXRETR 	= 8;
	TIMEOUT 	= 8;
	ACK 		= 0FH;
	NACK 		= 0H;

VAR
	dev: Device.Device;

	PROCEDURE RemoteReadFile*(CONST name: ARRAY OF CHAR): OFS.File;
		VAR i, check, len: SIZE; ch : CHAR; r: OFS.Rider; f: OFS.File;
	BEGIN 
		Device.WriteInt(dev, SerialLog.FR);
		Device.WriteStr(dev, name);
		Device.ReadInt(dev, len); i := 0;
		IF len = -1 THEN 
			f := NIL;
		ELSE 
			f := OFS.New(name); 
			IF f # NIL THEN OFS.Set(r, f, 0); END;
			check := 0;

			WHILE i < len DO
				Device.Read(dev, ch);
				check := check + ORD(ch);
				IF f # NIL THEN
					OFS.Write(r, ch);
				END;
				INC(i);
				IF (i MOD 200) = 0 THEN (* Primitive flow control *)
					Device.Write(dev, ch);
				END;
			END;
			Device.ReadInt(dev, i);
			IF i # check THEN 
				OFS.Close(f);
				f := NIL;
			END;
		END;
		RETURN f
	END RemoteReadFile;
	
	PROCEDURE SendBuf(num: SIZE; CONST p: ARRAY OF CHAR; len : SIZE);
		VAR i, check: SIZE;
	BEGIN
		Device.Write(dev, CHR(num));
		check := num;
		FOR i := 0 TO  len - 1 DO
			Device.Write(dev, p[i]); check := check + ORD(p[i])
		END;
		Device.Write(dev, CHR(check))
	END SendBuf;

	PROCEDURE RemoteWriteFile*(f: OFS.File);
		VAR len, j, time, timeout, avail, n, retr: SIZE; ch : CHAR; r: OFS.Rider; buf: ARRAY 2, PacketSize OF CHAR;
			name: OFS.FileName;
	BEGIN 
		len := OFS.Length(f);
		OFS.GetName(f, name);
		Device.WriteInt(dev, SerialLog.FS); Device.WriteStr(dev, name); 
		Device.WriteInt(dev, len); 
		OFS.Set(r, f, 0); OFS.Read(r, ch); j := 0; retr := 0;
		WHILE (len > 0) & (retr < MAXRETR) DO
			n := len DIV PacketSize MOD 2; buf[n][j] := ch; INC(j);
			WHILE (retr < MAXRETR) & (len # 0) & ((j = PacketSize) OR (j = len))  DO
 				SendBuf(n, buf[n], j);
 				time := Kernel.GetTime() + TIMEOUT;	(* 5 sec *)
				REPEAT
					timeout := Kernel.GetTime(); 
					 avail := Device.Available(dev)
				UNTIL (timeout > time) OR (avail > 0);
				IF avail > 0 THEN 
					Device.Read(dev, ch);
					IF ORD(ch) MOD 16 = NACK THEN
						IF ORD(ch) DIV 16 = n THEN  INC(retr) (* retransmission of same packet*)
						ELSE retr := MAXRETR (* stop not possible *)
						END;
					ELSIF ORD(ch) MOD 16 # ACK THEN INC(retr); (* retransmission  *)
					ELSE len := len - j; j := 0; (* send was ok *)
					END;
				ELSE INC(retr); (* retransmission of same packet*)
				END
			END;
			OFS.Read(r, ch);
		END; 
	END RemoteWriteFile;

BEGIN
	dev := Device.GetDevice(Platform.HostLink);
	IF dev = NIL THEN
		dev := Device.GetDevice("NULL");
	END;		
	Device.Open(dev);

END Tools.
