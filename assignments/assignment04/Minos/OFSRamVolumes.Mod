(* ported version of Minos to work with the ARM backend of the Fox Compiler Suite *)
(* ETH Oberon, Copyright 2006 ETH Zuerich Institut fuer Computersysteme, ETH Zentrum, CH-8092 Zuerich.
Refer to the "General ETH Oberon System Source License" contract available at: http://www.oberon.ethz.ch/ *)

MODULE OFSRamVolumes;  

(*@
	001 2007-02-07 tt: First version, adapted from orginal Oberon
*)

(* OFS.Volume implementation in ram. *)
IMPORT SYSTEM, OFS, Platform, Strings, Log;

TYPE 
	Volume* = POINTER TO RAMVolumeDesc;  
	RAMVolumeDesc = RECORD (OFS.VolumeDesc)
		baseAdr: SIZE
	END;  

VAR 
	(* Counter to generate unique names *)
	count: SIZE;  

(* Copy a memory block of size "len" from address "src" to address "dst". len MOD 4 must be 0! *)
	PROCEDURE CopyBlock( src, dst, len: ADDRESS);  
	VAR
		data: SIZE;
		bound, lowRAMAddress, highRAMAddress: ADDRESS;
		lnk: SIZE;
	BEGIN
		lnk := SYSTEM.LNK();
		
		ASSERT ( (len MOD 4) = 0 );  		
		
		lowRAMAddress := Platform.RAMLogicalLow; (* unsigned integer <- signed integer *)
		highRAMAddress := Platform.RAMLogicalHigh; (* unsigned integer <- signed integer *)
		
		ASSERT ( (src >= lowRAMAddress) & (src + len <= highRAMAddress) );		
		ASSERT ( (dst >= lowRAMAddress) & (dst + len <= highRAMAddress) );  
		
		bound := src + len;  
		WHILE src < bound DO 
			SYSTEM.GET( src, data );  SYSTEM.PUT( dst, data );  INC( src, 4 );  INC( dst, 4 );  
		END;  
	END CopyBlock;  

(* set a given memory block to 0 *)
	PROCEDURE ClearMem( adr, len: SIZE );  
	VAR bound: SIZE;  
	BEGIN 
		ASSERT ( (len MOD 4) = 0 );  
		ASSERT ( (adr >= Platform.RAMLogicalLow) & 
					    (adr + len <= Platform.RAMLogicalHigh) );  
		
		bound := adr + len;  
		WHILE adr < bound DO SYSTEM.PUT( adr, 0 );  INC( adr, 4 );  END;  
	END ClearMem;  

(* Get block from adr [1..size] of volume vol *)
	PROCEDURE GetBlock*( volume: OFS.Volume;  adr: SIZE;  
											  VAR blk: ARRAY OF SYSTEM.BYTE; ofs: SIZE; VAR res: INTEGER );  
	VAR vol: Volume;  
	BEGIN
		vol := volume( Volume );  

		ASSERT( (adr >= 1) & (adr <= vol.size));
		ASSERT ( ((vol.baseAdr + adr * vol.blockSize) <= Platform.RAMLogicalHigh) & 
		    (vol.baseAdr >= Platform.RAMLogicalLow));

		(*  	ASSERT(SIZE(blk) >= vol.blockSize); *)  (* With the current compiler, this does unfortunately not work *)
		
		CopyBlock( vol.baseAdr + vol.blockSize * (adr - 1), ADDRESSOF( blk ) + ofs, 
						   vol.blockSize );
		res := OFS.Ok;
	END GetBlock;  

(* Put block to adr [1..size] of volume vol *)
	PROCEDURE PutBlock*( volume: OFS.Volume;  adr: SIZE;  
											  VAR blk: ARRAY OF SYSTEM.BYTE; ofs: SIZE; VAR res: INTEGER);  
	VAR vol: Volume;  
	BEGIN 
		vol := volume( Volume );  
		ASSERT( (adr >= 1) & (adr <= vol.size));
		ASSERT ( ((vol.baseAdr + adr * vol.blockSize) <= Platform.RAMLogicalHigh) & 
		    (vol.baseAdr >= Platform.RAMLogicalLow));

		(* 	ASSERT(SIZE(blk) >= vol.blockSize); *)
		
		CopyBlock( ADDRESSOF( blk[0] ) + ofs, vol.baseAdr + vol.blockSize * (adr - 1), 
						   vol.blockSize );  
		res := OFS.Ok;
	END PutBlock;  

(* Default finalizer of this Volume *)
	PROCEDURE Finalize*( vol: OFS.Volume );  
	BEGIN 
		vol( Volume ).baseAdr := 0;  OFS.DefaultFinalizeVol( vol )
	END Finalize;  

(** Generate a new ramdisk at adress "adr" in memory of size "size" in bytes and blocksize "blocksize"  *)
	PROCEDURE New*( adr, size, blocksize: SIZE;  init: BOOLEAN; VAR vol: Volume );  
	BEGIN
		vol := NIL;
		IF (size > 0) & (blocksize > 0) THEN 
			NEW( vol );  
			vol.baseAdr := adr;   (* base address of RAMDisk in memory *)
			IF init THEN ClearMem( adr, blocksize );  END;  
			SYSTEM.PUT( adr, OFS.DirMark );   (* Preformat RamDisk *)
			vol.name := "RAM";  Strings.AppendInt( vol.name, count );  
			INC( count );  vol.blockSize := blocksize;  vol.size := size;  vol.flags := {};  
			vol.AllocBlock := OFS.DefaultAllocBlock;  
			vol.FreeBlock := OFS.DefaultFreeBlock;  
			vol.MarkBlock := OFS.DefaultMarkBlock;  
			vol.Marked := OFS.DefaultMarked;  vol.Available := OFS.DefaultAvailable;  
			vol.GetBlock := GetBlock;  vol.PutBlock := PutBlock;  
			vol.Sync := OFS.DefaultSync;  vol.Finalize := Finalize;  
			OFS.InitVol( vol );  
		ELSE Log.S( "OFSRAMVolumes: bad parameters" )
		END
	END New;  

(*
(* Used to cleanup all volumes *)
PROCEDURE Cleanup*;
VAR fs: OFS.FileSystem;
BEGIN
	REPEAT	(* unmount all file systems using our volume *)
		fs := OFS.First();	(* look for fs to unmount *)
		WHILE (fs # NIL) & ((fs.vol = NIL) OR ~(fs.vol IS Volume)) DO
			fs := OFS.Next(fs)
		END;
		IF fs # NIL THEN OFS.Remove(fs) END
	UNTIL fs = NIL
END Cleanup;
*)

	(* Mount the default ram disk *)
	PROCEDURE MountRamDisk;
	VAR
		prefix: OFS.Prefix;
		vol: Volume;
	BEGIN
		prefix := "RAM";
		New( Platform.RAMDiskBase, Platform.RAMDiskSize, Platform.OFSBlockSize, TRUE, vol );
	
		IF vol # NIL THEN
			OFS.NewFS(prefix, TRUE, vol);
		ELSE
			Log.SL("Could not mount ramdisk");
		END;
	END MountRamDisk;

BEGIN 
	count := 0;  	
	MountRamDisk;	
END OFSRamVolumes.
