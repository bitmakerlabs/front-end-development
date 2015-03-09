#!/bin/sh

# We wrap this whole script in a function, so that we won't execute
# until the entire script is downloaded.
# That's good because it prevents our output overlapping with curl's.
# It also means that we can't run a partially downloaded script.
# We don't indent because it would be really confusing with the heredocs.
run_it () {

# Now, on to the actual installer!

## NOTE sh NOT bash. This script should be POSIX sh only, since we don't
## know what shell the user has. Debian uses 'dash' for 'sh', for
## example.

PLATFORM=$(uname -s)

cat <<EOF

Bitmaker Labs Front End Development Setup
=========================================

This installer will setup your computer with all of the tools you need.
There are three tools that we'll be depending on throughout the course:

1.  Git
    Git is a free and open source distributed version control system
    that we'll depend on to track changes, back up and collaborate on
    code we write in class.

2.  NodeJS
    Node is a platform that allows us to run the V8 JavaScript engine,
    the very same one that the Chrome web browser uses to interpret JavaScript,
    on the command line on our computer. We need it to run some tools
    that will help us scaffold new projects and render our Sass files
    into regular CSS.

3.  Yeoman
    Yeoman is a combination of three tools that will help you quickly
    create new projects with everything you need to get working on your
    prototypes quickly. The three tools are Yo, a scaffolding tool that
    will setup project directories and files for you, Grunt, a task runner,
    and Bower, a package manager that will fetch JavaScript and stylesheets
    from around the web for use in your project.

NOTE: Windows users should have installed Git and NodeJS prior to running this installer.

EOF

printf "Press enter when you're ready to start (or 'q' to quit): "
read START < /dev/tty

if [ "$START" = "q" ]; then
  exit 1
fi


if [ "$PLATFORM" = "Darwin" ]; then
  if [ ! "$(command -v brew)" ]; then
    echo
    echo "The first step is to install Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
  else
    echo
    echo "You've got Homebrew installed. Let's update it before we start."
    brew update
  fi

  echo
  echo "Run brew doctor to see that everything is setup properly"
  brew doctor

  cat <<"EOF"

Inspect the above output carefully!
===================================

Warnings most likely won't cause problems, so you can continue if that's all you see.
If there are any ERRORS listed, they'll need to be fixed before continuing.

Here are some common things to look for:

*   If it says 'Ready to brew', you're good to go!

*   If it mentions that you need to install XCode or Command Line Tools,
    you'll have to download it from https://developer.apple.com using your
    iTunes username and password

*   Report any other errors to the Google Group or fed@bitmakerlabs.com

EOF

  printf "Press enter when you're ready to continue (or 'q' to quit): "
  read RESULT < /dev/tty

  if [ "$RESULT" = "q" ]; then
    exit 1
  fi

  echo
  echo "Change the PATH to have /usr/local/bin at the start"
  if [[ -e "$HOME/.zshrc" ]]; then
    echo "export PATH=\"/usr/local/bin:$PATH\"" > $HOME/.zshrc
    source $HOME/.zshrc
  else
    echo "export PATH=\"/usr/local/bin:$PATH\"" > $HOME/.bash_profile
    source $HOME/.bash_profile
  fi

  echo
  echo "Ensure current user is the owner of all files and folders in /usr/local"
  sudo chown -R $USER:admin /usr/local

  if [ ! "$(brew leaves | grep git)" ]; then
    echo
    echo "Install Git"
    brew install git
  fi

  if [ ! "$(brew leaves | grep node)" ]; then
    echo
    echo "Install Node"
    brew install node
  fi
elif [ "$PLATFORM" = "Linux" ]; then
  echo "\nInstall Git and Node"
  sudo apt-get update
  sudo apt-get install -y build-essential git

  curl -sL https://deb.nodesource.com/setup | sudo bash -
  sudo apt-get install -y nodejs

# Check for Git Bash (not needed as far as I know right now)
# elif [ "$(expr substr $PLATFORM 1 10)" == "MINGW32_NT" ]; then

fi

if [ "$(command -v npm)" ]; then
  echo "\nInstall Yeoman, Grunt CLI and Bower via NPM"
  npm install -g yo grunt-cli bower generator-bitmaker-prototyping
else
  cat <<"EOF"

ERROR: npm isn't properly installed on your system.

This most likely means one of the previous steps failed.
Save the terminal output to a file and email it to fed@bitmakerlabs.com
to get help troubleshooting this problem.

EOF

  exit 1
fi

cat <<EOF

Installation complete!
======================

Your system is now set up with all the tools we'll need in this course.
From here you can generate new projects by following these steps:

1.  Change into the directory where you store all of your projects
    (e.g. cd projects)

2.  Run 'yo bitmaker-prototyping'

3.  Answer the questions it asks you and watch it go!
    TIP: Accepting all the defaults by simply pressing enter is a good way to start

4.  Change into your new project directory and get to work!
    (e.g. cd <your-project-name>)

If you had any issues with the installer, send an email to fed@bitmakerlabs.com

Happy coding!

EOF

trap - EXIT
}

run_it