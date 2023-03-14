SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_barcode_ean13_outputWidths] (
@value VARCHAR(12),
  @widths VARCHAR(44) NULL OUTPUT
  )

AS
  /*
    Written by Scott Shaffer on 3/24/2022
    Purpose: convert input value for a barcode to necessary barcode widths for ean13 standards
  */
BEGIN
  SET XACT_ABORT ON
  SET NOCOUNT ON
  
  DECLARE @structure VARCHAR(6)       --selects structure based on start code
  DECLARE @substructure VARCHAR(1)    --selects the substructure based on current position
  DECLARE @iteration INT              --selects current iteration
  DECLARE @structCursorPos INT        --selects the current cursor position in the loops for the substructure
  DECLARE @valCursorPos INT           --selects the current cursor position in the loops for the value
  DECLARE @subWidth VARCHAR(4)        --selects the widths value for a certain int value

  SET @iteration = 0
  SET @structCursorPos = 1
  SET @valCursorPos = 2



  /*  select structure rule based on the first digit  */
  IF SUBSTRING(@value,1,1) = 0 BEGIN SET @structure = 'LLLLLL' END  --same thing as upca
  IF SUBSTRING(@value,1,1) = 1 BEGIN SET @structure = 'LLGLGG' END
  IF SUBSTRING(@value,1,1) = 2 BEGIN SET @structure = 'LLGGLG' END
  IF SUBSTRING(@value,1,1) = 3 BEGIN SET @structure = 'LLGGGL' END
  IF SUBSTRING(@value,1,1) = 4 BEGIN SET @structure = 'LGLLGG' END
  IF SUBSTRING(@value,1,1) = 5 BEGIN SET @structure = 'LGGLLG' END
  IF SUBSTRING(@value,1,1) = 6 BEGIN SET @structure = 'LGGGLL' END
  IF SUBSTRING(@value,1,1) = 7 BEGIN SET @structure = 'LGLGLG' END
  IF SUBSTRING(@value,1,1) = 8 BEGIN SET @structure = 'LGLGGL' END
  IF SUBSTRING(@value,1,1) = 9 BEGIN SET @structure = 'LGGLGL' END



--first character is encoded using the structure rule above.
--six characters on left side differ in widths value depending if the position is an L or a G.
--five characters on the right side always follow the same widths rule regardless of position.
--the sixth character on the right is added on later by the ean_13_checksum procedure.
--total, 13 chars: 1 structure code, 6 left, 5 right, 1 checsksum



      WHILE @iteration <= 5
      BEGIN
        IF SUBSTRING(@structure, @structCursorPos, 1) = 'L' BEGIN SELECT @subWidth = widthsLR FROM barcodeEAN13_data WHERE outputValue = SUBSTRING(@value, @valCursorPos, 1) END    --select the output widths depending on current cursor positioning and substructure
        IF SUBSTRING(@structure, @structCursorPos, 1) = 'G' BEGIN SELECT @subWidth = widthsG  FROM barcodeEAN13_data WHERE outputValue = SUBSTRING(@value, @valCursorPos, 1) END

        SET @iteration = @iteration + 1
        SET @valCursorPos = @valCursorPos + 1
        SET @structCursorPos = @structCursorPos + 1
        SELECT @widths = CONCAT(@widths, @subWidth)    --add new output subwidth to the complete output
      END

      WHILE @iteration > 5 AND @iteration <= 11      --for the right 5 characters, select the output widths depending on current cursor positioning
      BEGIN
        SELECT @subWidth = widthsLR FROM barcodeEAN13_data WHERE outputValue = SUBSTRING(@value, @valCursorPos, 1) 
          
        SET @iteration = @iteration + 1
        SET @valCursorPos = @valCursorPos + 1
        SET @structCursorPos = @structCursorPos + 1 
        SELECT @widths = CONCAT(@widths, @subWidth)    --add new output subwidth to the complete output
      END



  SELECT @widths
END
GO
