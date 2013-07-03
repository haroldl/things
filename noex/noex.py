#!/usr/bin/env python

"""
noex [-p exit_string] command

Run the command given and watch for a Java-style exception message on stdout.
If the exit_string is seen on the child command's standard output, then noex
will terminate the child process immediately.

exit_string defaults to "Exception:"

stdin, stdout and stderr are passed through to the child command and work
normally. noex will exit with the exit code of the child process.
"""

import sys
import platform
from os import O_NONBLOCK
from errno import EWOULDBLOCK
from fcntl import fcntl, F_GETFL, F_SETFL
from subprocess import Popen, PIPE

class StreamScanner:
  """
  Injest a stream of bytes looking for a message that indicates that we should
  exit early.
  """

  def __init__(self, target_string):
    self.found_target = False
    self.target_string = target_string
    self.target_len = len(target_string)
    self.matched_chars = [False for char in self.target_string]

  def should_exit(self):
    """
    Have this scanner seen the target string?
    """
    return self.found_target

  def injest(self, bytes):
    """
    Process partial input, watching for the target pattern which might be seen
    split across multiple invocations of this method.
    """
    if self.found_target:
      return
    for byte in bytes:
      for i in xrange(self.target_len-1, 0, -1):
        prior_matched = self.matched_chars[i-1]
        this_matches = byte == self.target_string[i]
        self.matched_chars[i] = prior_matched and this_matches
      self.matched_chars[0] = byte == self.target_string[0]
      if self.matched_chars[self.target_len-1]:
        self.found_target = True
        return

def make_stream_non_blocking(stream):
    """
    Make the given stream, such as sys.stdin, non-blocking.
    """
    fd = stream.fileno()
    fl = fcntl(fd, F_GETFL)
    fcntl(fd, F_SETFL, fl | O_NONBLOCK)

def read_non_blocking(stream, buffer_size=1024):
    """
    Read from the stream, but silently ignore the IOError thrown when there is
    nothing available to read.
    """
    try:
        return stream.read(buffer_size)
    except IOError as e:
        if e.errno == EWOULDBLOCK:
            pass
        else:
            raise e

def copy_remaining_output(child):
  """
  After the child process ends we still want to write out any remaining output
  so that it isn't lost. Keep going until there is nothing found from the child
  process's stdout or stderr.
  """
  done_with_err = False
  done_with_out = False
  try:
    while not(done_with_err) or not(done_with_out):
      if child.stderr.closed:
        done_with_err = True
      if not(done_with_err):
        err = read_non_blocking(child.stderr)
        if err is not None and len(err) > 0:
          sys.stderr.write(err)
        else:
          done_with_err = True

      if child.stdout.closed:
        done_with_out = True
      if not(done_with_out):
        out = read_non_blocking(child.stdout)
        if out is not None and len(out) > 0:
          sys.stdout.write(out)
          sys.stdout.flush()
        else:
          done_with_out = True
  except IOError:
    pass

def terminate_and_wait(child):
  """
  Terminate the child process and wait until it has finished before returning.
  """
  child.terminate()
  while child.returncode is None:
    child.poll()

if __name__ == '__main__':
  if platform.system() == 'Windows':
    # The non-blocking I/O calls :-(
    print >> sys.stderr, "This probably won't work on Windows, sorry!"
    sys.exit(1)

  if (len(sys.argv)) < 2:
    print >> sys.stderr, "[noex] Error: %s needs a command to run!" % sys.argv[0]
    sys.exit(1)

  command = sys.argv[1:]
  pattern = "Exception:"
  if sys.argv[1] == "-p":
    pattern = sys.argv[2]
    command = sys.argv[3:]

  child = Popen(command, stdout=PIPE, stderr=PIPE)
  make_stream_non_blocking(child.stdout)
  make_stream_non_blocking(child.stderr)
  scanner = StreamScanner(pattern)

  try:
    child.poll()
    while child.returncode is None:
      if scanner.should_exit():
        print >> sys.stderr, "[noex] Terminating child process, found", pattern
        terminate_and_wait(child)
        break

      err = read_non_blocking(child.stderr)
      out = read_non_blocking(child.stdout)

      if err is not None and len(err) > 0:
        scanner.injest(err)
        sys.stderr.write(err)

      if out is not None and len(out) > 0:
        sys.stdout.write(out)
        sys.stdout.flush()

      child.poll()
  except KeyboardInterrupt:
    terminate_and_wait(child)

  copy_remaining_output(child)
  sys.exit(child.returncode)
