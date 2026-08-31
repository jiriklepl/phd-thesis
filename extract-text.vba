Sub ExtractNotesToTextFile()
    Dim sld As Slide
    Dim shp As Shape
    Dim notesText As String
    Dim currentNotes As String
    Dim fileNum As Integer
    Dim filePath As String

    notesText = ""

    ' Loop through all slides in the active presentation
    For Each sld In ActivePresentation.Slides
        currentNotes = ""

        ' Check if the slide has a notes page
        If sld.HasNotesPage Then
            For Each shp In sld.NotesPage.Shapes
                ' Target the specific body placeholder that holds the speaker notes
                If shp.PlaceholderFormat.Type = ppPlaceholderBody Then
                    If shp.HasTextFrame Then
                        If shp.TextFrame.HasText Then
                            currentNotes = shp.TextFrame.TextRange.Text
                        End If
                    End If
                End If
            Next shp
        End If

        ' Append the slide notes with two new lines and the "---" separator
        If notesText = "" Then
            notesText = currentNotes
        Else
            notesText = notesText & vbCrLf & vbCrLf & "---" & vbCrLf & vbCrLf & currentNotes
        End If
    Next sld

    ' Define the output path (saves directly to your Desktop)
    filePath = CreateObject("WScript.Shell").SpecialFolders("Desktop") & "\PowerPoint_Notes.txt"

    ' Write the aggregated string into the text file
    fileNum = FreeFile
    Open filePath For Output As #fileNum
    Print #fileNum, notesText
    Close #fileNum

    MsgBox "All notes have been successfully saved to your Desktop as 'PowerPoint_Notes.txt'!", vbInformation, "Extraction Complete"
End Sub
