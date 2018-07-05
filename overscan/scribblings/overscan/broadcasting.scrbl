#lang scribble/manual
@require[@for-label[overscan
                    gstreamer
                    racket/base
                    racket/contract
                    racket/class
                    ffi/unsafe/introspection]]

@title[#:tag "broadcasting"]{Broadcasting}

A @deftech{broadcast} is a global @tech{pipeline} that can be controlled through the Overscan DSL, and provides a global event bus.

@defproc[(make-broadcast [video-source (is-a?/c element%)]
                         [audio-source (is-a?/c element%)]
                         [flv-sink (is-a?/c element%)]
                         [#:name name (or/c string? false/c)]
                         [#:preview video-preview (is-a?/c element%)]
                         [#:monitor audio-monitor (is-a?/c element%)]
                         [#:h264-encoder h264-encoder (is-a?/c element%)]
                         [#:aac-encoder aac-encoder (is-a?/c element%)])
                         (or/c (is-a?/c pipeline%) #f)]{
  Create a @tech{pipeline} that encodes a @racket[video-source] into h264 with @racket[h264-encoder], an @racket[audio-source] into aac with @racket[aac-encoder], muxes them together into an flv, and then sends that final flv to the @racket[flv-sink].
}

@defproc[(broadcast [video-source (is-a?/c element%) (videotestsrc)]
                    [audio-source (is-a?/c element%) (audiotestsrc)]
                    [flv-sink (is-a?/c element%) (filesink (make-temporary-file))]
                    [#:name name (or/c string? false/c)]
                    [#:preview video-preview (is-a?/c element%)]
                    [#:monitor audio-monitor (is-a?/c element%)]
                    [#:h264-encoder h264-encoder (is-a?/c element%)]
                    [#:aac-encoder aac-encoder (is-a?/c element%)])
                    (is-a?/c pipeline%)]{
  Like @racket[make-broadcast], this procedure creates a pipeline, but will then call @racket[start] to promote it to the current @tech{broadcast}.
}

@defproc[(get-current-broadcast) (is-a?/c pipeline%)]{
  Gets the current @tech{broadcast} or raises an error if there is none.
}

@defproc[(start [pipeline (is-a?/c pipeline%)]) thread?]{
  Transforms the given @racket[pipeline] into the current @tech{broadcast} by creating an event listener on its @tech{bus} and setting its state to @racket['playing]. The returned thread is the listener polling the pipeline's bus.
}

@defproc[(on-air?) boolean?]{
  Returns @racket[#t] if there is a current broadcast, @racket[#f] otherwise.
}

@defproc[(stop [#:timeout timeout exact-nonnegative-integer? 5])
         (one-of/c 'failure 'success 'async 'no-preroll)]{
  Stops the current @tech{broadcast} by sending an @tech{EOS} event. If the state of the pipeline cannot be changed within @racket[timeout] seconds, an error will be raised.
}

@defproc[(kill-broadcast) void?]{
  Stops the current @tech{broadcast} without waiting for a downstream @tech{EOS}.
}

@defthing[overscan-logger logger?]{
  A @tech{logger} with a topic called @racket['Overscan]. Used by Overscan's event bus to log messages.
}

@section{Twitch}

@defmodule[overscan/twitch]

@hyperlink["https://www.twitch.tv/"]{Twitch.tv} is a live streaming community. To broadcast to Twitch, get a stream key from the dashboard settings and use it as a parameter to @racket[twitch-sink] with @racket[twitch-stream-key].

@defparam[twitch-stream-key key string?
          #:value (getenv "TWITCH_STREAM_KEY")]{
  A parameter that defines the current stream key for broadcasting to Twitch.tv.
}

@defproc[(twitch-sink [#:test bandwidth-test? boolean? #f]) rtmpsink?]{
  Create a @tech{rtmpsink} set up to broadcast upstream data to Twitch.tv. If @racket[bandwidth-test?] is @racket[#t], the stream will be configured to run a test, and won't be broadcast live. This procedure can be parameterized with @racket[twitch-stream-key].
}
