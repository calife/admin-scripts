#!/bin/bash -
# demonstrates all zenity functions
# also demonstrates
#+ FUNCNEST Limiting recursion
#+ lower casing ${selection,,}
#+ removing spaces ${choice// }
#+ file_selection with starting directory
#+ readlink to get final destination
#+ brief option to file (-b)

finale(){
  # demo - shows zenity return value(s)
  zenity --info \
    --title="Zenity returned:" \
    --window-icon=/usr/share/icons/gnome/22x22/emotes/face-worried.png \
    --width=400 \
    --text="$@"
  [ $? -eq 1 ] && exit 0
}

calendar(){
  result=$( \
    zenity --calendar \
	--title="Calendar demo" \
	--date-format="%A, %B %-d, %Y" \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

entry1(){
  result=$( \
    zenity --entry \
      --title="Entry demo (visible)" \
      --text="Text entry dialogue" \
      --width=400 \
      --entry-text="This sentence can be changed." \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

entry2(){
  result=$( \
    zenity --entry \
      --title="Entry demo 2 (invisible)" \
      --hide-text \
      --text="Text entry dialogue" \
      --width=400 \
      --entry-text="This sentence can be changed." \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

error(){
  zenity --error \
    --title="Error demo" \
    --text="This is a sample error message"
  [ $? -eq 1 ] && exit 0
}

fileselection(){
  # --filename=FILENAME --multiple --directory --save --separator=SEPARATOR --confirm-overwrite --file-filter=NAME | PATTERN1 PATTERN2
  result=$( \
    zenity --file-selection \
      --title "File selection demo" \
      --filename=/etc/ \
  )
  [ $? -eq 1 ] && exit 0
  if [ -h $result ]; then
    reallink=$(readlink -f $result)
    txt=$(file -b $reallink)
    finale "$result\nbut this is a symbolic link to\n$reallink\nwhich is $txt)"
  else
    finale "$(file $result)"
  fi
}

info(){
  zenity --info \
    --title="Info demo" \
    --width=400 \
    --text="This is info text"
  [ $? -eq 1 ] && exit 0
}

list(){
  finale "This demo is using the list type with radio buttons\nThis next will show a check list"
  selection=$( \
    zenity --list \
      --title="Zenity Demonstration" \
      --width=640 --height=480 \
      --text="List type wih check boxes" \
      --column="Col 1" --checklist \
      --column "Item" \
        TRUE Oranges \
        TRUE Bananas \
        FALSE Cherios \
        FALSE Cigarettes \
  )
  [ $? -eq 1 ] && exit 0
  finale "$selection"
}

notification(){
  echo "message:You have been notified. The rest is up to you" | zenity --notification --listen --timeout 1
  [ $? -eq 1 ] && exit 0
}

progress(){
  (for i in $(seq 0 10 100);do echo "# $i percent complete";echo $i;sleep 1;done) | zenity --progress  --title="Progress demo" --width=800
  [ $? -eq 1 ] && exit 0
}

question(){
  zenity --question \
    --title="Question demo" \
    --text="Ready to proceed?" \
    --ok-label="I'll be careful" \
    --cancel-label="Get me out of here"
  [ $? -eq 1 ] && exit 0
}

textinfo1(){
  FILE=~/.bashrc
  zenity --text-info \
    --title="Text info demo" \
    --width 640 --height 480 \
    --filename=$FILE \
    --checkbox="This is acceptable."
  [ $? -eq 1 ] && exit 0
  finale "You accepted"  
}

textinfo2(){
  FILE=~/.bashrc
  zenity --text-info \
    --title="Text info demo" \
    --width 640 --height 480 \
    --filename=$FILE
  [ $? -eq 1 ] && exit 0
  finale "You accepted"  
}

warning(){
  zenity --warning \
    --title="Warning demo" \
    --width=400 \
    --text="This is a demo warning"
  [ $? -eq 1 ] && exit 0
}

scale1(){
  result=$( \
  zenity --scale \
    --title="Scale demo" \
    --text="How old are you")
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

scale2(){
  result=$( \
    zenity --scale \
      --title="Scale demo" \
      --print-partial \
      --text="How old are you" \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

scale3(){
  result=$( \
    zenity --scale \
      --title="Scale demo" \
      --value=50 \
      --max-value=450 \
      --min-value=50 \
      --step=5 \
      --text="Your aproximate weight" \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

colorselection1(){
  TITLE="Color selection 1"
  result=$( \
    zenity --color-selection \
      --title="$TITLE" \
      --color="#123456")
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

colorselection2(){
  TITLE="Color selection 2 with palette"
  result=$( \
    zenity --color-selection \
      --title="$TITLE" \
      --show-palette \
      --color="#123456" \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

password(){
  result=$( \
    zenity --password \
      --title="Password demo" \
      --username)
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

forms(){
  result=$( \
    zenity --forms \
      --title="Forms demo" \
      --text="Please fill out this form" \
      --add-entry=Name \
      --add-entry="Street Address" \
      --add-entry=City \
      --add-entry=State \
      --add-entry=Zip \
      --add-password=Password \
      --add-calendar="Date of birth" \
      --forms-date-format="%A, %B %-d, %Y" \
  )
  [ $? -eq 1 ] && exit 0
  finale "$result"
}

declare -r FUNCNEST=2

while :;do
  selection=$( \
    # Column 1 is a radio button or a checkbox and is pre-selected if TRUE
    # Column 2 is demo function name and is hidden from list
    zenity --list \
      --radiolist \
      --title="Zenity Demonstration" \
      --width=800 --height=600 \
      --text="Dialogue Type" \
        --column="Select" \
        --column="Hidden" \
        --column="Option" \
        --column="Description" \
        --hide-column=2 \
	  FALSE Calendar "calendar" "Choose a date - mm/dd/yyyy, mm/today/yyyy uses strftime"\
          FALSE "Entry 1" entry "Enter/Edit some text. (Visible)" \
          FALSE "Entry 2" entry "Enter/Edit some text. (Invisible)" \
          FALSE Error error "Show a error message" \
          FALSE "File Selection" file-selection "Select file(s) from fm type dialogue." \
          FALSE Info info "Show an information dialgoue" \
          FALSE List list "Radio buttons (This demo) and checkboxes" \
          FALSE Notification notification "Unfortunately influenced by Gnome-3" \
          FALSE Progress progress "Process % progress bar" \
          FALSE Question question "Ask question with OK and Cancel buttons" \
          FALSE "Text info 1" text-info "Display text file contents with checkbox" \
          FALSE "Text info 2" text-info "Display text file contents without checkbox" \
          FALSE Warning warning "Display a warning message " \
          FALSE "Scale 1" scale "Choose a number using bar slider - Returns final value" \
          FALSE "Scale 2" scale "Choose a number using bar slider - Returns all values" \
          FALSE "Scale 3" scale "Choose a number using bar slider - Step 5 (with arrow, not mouse)" \
          FALSE "Color Selection 1" color-selection "Select a color" \
          FALSE "Color Selection 2" color-selection "Select a color - shows palette" \
          FALSE Password password "Enter a Username and Password. Note: --width option doesn't work" \
          FALSE Forms forms "Display a data entry form" \
  )
  [ $? -eq 0 ] || exit 0
  choice=${selection,,}	# lowercase all
  ${choice// }		# eliminate all spaces
done
