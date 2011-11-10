[CCode(cheader_filename = "fcgiapp.h")]
namespace FastCGI {

	[CCode(cname = "FCGX_UNSUPPORTED_VERSION")]
	public const int UNSUPPORTED_VERSION;
	[CCode(cname = "FCGX_PROTOCOL_ERROR")]
	public const int PROTOCOL_ERROR;
	[CCode(cname = "FCGX_PARAMS_ERROR")]
	public const int PARAMS_ERROR;
	[CCode(cname = "FCGX_CALL_SEQ_ERROR")]
	public const int CALL_SEQ_ERROR;

	/**
	 * The state of a FastCGI stream.
	 *
	 * Streams are modeled after the {@link GLib.FileStream}.
	 * (We wouldn't need our own if platform vendors provided a
	 * standard way to subclass theirs.)
	 * The state of a stream is private and should only be accessed
	 * by the procedures defined below.
	 */
	[CCode(cname = "FCGX_Stream", free_function = "FCGX_FClose")]
	[Compact]
	public class Stream {
		public bool isReader;
		public bool isClosed;

		/**
		 * Repositions an input stream to the start of FCGI_DATA.
		 *
		 * If the preconditions are not met sets the stream error code to
		 * {@link CALL_SEQ_ERROR}.
		 *
		 * @return 0 for a normal return, < 0 for error
		 */
		[CCode(cname = "FCGX_StartFilterData")]
		public int start_filter();

		/**
		 * Sets the exit status for stream's request.
		 *
		 * The exit status is the status code the request would have exited with,
		 * had the request been run as a CGI program. You can call this
		 * several times during a request; the last call before the request ends
		 * determines the value.
		 */
		[CCode(cname = "FCGX_SetExitStatus", instance_pos = 1.2)]
		public void set_exit_status(int status);

		/**
		 * Reads a byte from the input stream and returns it.
		 *
		 * @return The byte, or {@link GLib.FileStream.EOF} if the end of input has been reached.
		 */
		[CCode(cname = "FCGX_GetChar")]
		public int getc();

		/**
		 * Pushes back the character onto the input stream.
		 *
		 * One character of pushback is guaranteed once a character
		 * has been read. No pushback is possible for EOF.
		 *
		 * @return c if the pushback succeeded, {@link GLib.FileStream.EOF} if not.
		 */
		[CCode(cname = "FCGX_UnGetChar", instance_pos = 1.2)]
			public int ungetc(int c);

		/**
		 * Reads up to consecutive bytes from the input stream
		 * into the character array.
		 *
		 * Performs no interpretation of the input bytes.
		 * @return Number of bytes read.  If result is smaller than the buffer size,
		 * end of input has been reached.
		 */
		[CCode(cname = "FCGX_GetStr", instance_pos = 1.2)]
		public int read(uint8[] buffer);

		[CCode(cname = "FCGX_GetLine", instance_pos = 1.2)]
		public unowned string? gets(uint8[] buffer);

		/**
		 * Returns true if end-of-file has been detected while reading from stream.
		 *
		 * Note that this may return false, yet an immediately
		 * following {@link getc} may return EOF. This function, like
		 * the standard C stdio function {@link GLib.FileStream.eof}, does not provide the
		 * ability to peek ahead.
		 */
		[CCode(cname = "FCGX_HasSeenEOF")]
		public bool has_seen_eof();

		/**
		 * Writes a byte to the output stream.
		 *
		 * @return The byte, or {@link GLib.FileStream.EOF} if an error occurred.
		 */
		[CCode(cname = "FCGX_PutChar", instance_pos = 1.2)]
		public int putc(int c);

		/**
		 *  Writes the buffer into the output stream.
		 *
		 *  Performs no interpretation of the output bytes.
		 *
		 * @return Number of bytes written for normal return, or {@link GLib.FileStream.EOF} if an error occurred.
		 */
		[CCode(cname = "FCGX_PutStr", instance_pos = 1.3)]
		public int put_str(uint8[] buffer);

		/**
		 * Writes a string to the output stream.
		 * @return Number of bytes written for normal return, or {@link GLib.FileStream.EOF} if an error occurred.
		 */
		[CCode(cname = "FCGX_PutS", instance_pos = -1)]
		public int puts(string str);

		/**
		 * Performs printf-style output formatting and writes the results to the output stream.
		 * @return Number of bytes written for normal return, or {@link GLib.FileStream.EOF} if an error occurred.
		 */
		[CCode(cname = "FCGX_FPrintF")]
		[PrintfFormat]
		public int printf(string format, ...);

		[CCode(cname = "FCGX_VFPrintF")]
		public int vprintf(string format, va_list arg);

		/**
		 * Flushes any buffered output.
		 *
		 * Server-push is a legitimate application of this method.
		 * Otherwise, this method is not very useful, since {@link accept}
		 * does it implicitly. Calling it in non-push applications
		 * results in extra writes and therefore reduces performance.
		 */
		[CCode(cname = "FCGX_FFlush")]
		public bool flush();

		/**
		 * Return the stream error code.
		 * @return 0 means no error, > 0 is an errno(2) error, < 0 is an FastCGI error.
		 */
		[CCode(cname = "FCGX_GetError")]
		public int get_error();

		/**
		 * Clear the stream error code and end-of-file indication.
		 */
		[CCode(cname = "FCGX_ClearError")]
		public void clear_error();

		/**
		 * Create a FCGX_Stream (used by cgi-fcgi).
		 *
		 * This shouldn't be needed by a FastCGI application.
		 */
		[CCode(cname = "FCGX_CreateWriter")]
		public static Stream create_writer(int socket, int requestId, int bufflen, int streamType);
	}

	/**
	 * CGI parameters
	 */
	[CCode(cname = "FCGX_ParamArray")]
	[SimpleType]
	public struct parameters {
		[CCode(cname = "FCGX_GetParam", instance_pos = -1)]
		public unowned string? get(string name);
		[CCode(array_null_terminated = true, array_length = false)]
		public unowned string[] get_all() {
			return (string[]) this;
		}
	}

	[CCode(cname = "int", cprefix = "FCGI_")]
	[Flags]
	public enum RequestFlags {
		[CCode(cname = "0")]
		NONE,
		/**
		 * Do not restart upon being interrupted.
		 */
		FAIL_ACCEPT_ON_INTR
	}

	/**
	 * State associated with a request.
	 */
	[CCode(cname = "FCGX_Request", has_type_id = false, destroy_function = "")]
	public struct request {
		public int requestId;
		public int role;
		public Stream @in;
		public Stream @out;
		public Stream err;
		[CCode(cname = "envp")]
		public parameters environment;

		public unowned string? @get(string name) {
			return environment[name];
		}

		/**
		 * Initialize a request.
		 *
		 * @param sock is a file descriptor returned by {@link open_socket} or 0 (default).
		 *
		 * @return 0 upon success.
		 */
		[CCode(cname = "FCGX_InitRequest")]
		public static int init(out request request, int sock = 0, RequestFlags flags = RequestFlags.NONE);

		/**
		 * Accept a new request
		 *
		 * Thread-safe.
		 *
		 * Finishes the request accepted by (and frees any
		 * storage allocated by) the previous call.
		 * Creates input, output, and error streams and
		 * assigns them to in, out, and err respectively.
		 * Creates a parameters data structure.
		 *
		 * DO NOT retain pointers to the envp or any strings
		 * contained in it, since these will be freed
		 * by the next call or a call to {@link finish}.
		 *
		 * @return 0 for successful call, -1 for error.
		 */
		[CCode(cname = "FCGX_Accept_r")]
		public int accept();

		/**
		 * Finish the request
		 *
		 * Thread-safe.
		 *
		 * Finishes the request accepted by (and frees any
		 * storage allocated by) the previous call to {@link accept}.
		 *
		 * DO NOT retain pointers to the envp array or any strings
		 * contained in it, since these will be freed.
		 */
		[CCode(cname = "FCGX_Finish_r")]
		public void finish();

		[CCode(cname = "FCGX_Free")]
		[DestroysInstance]
		public void close(bool close = true);
		[DestroysInstance]
		public void release() {
			close(false);
		}
	}

	/**
	 * Is this process a CGI process rather than a FastCGI process.
	 */
	[CCode(cname = "FCGX_IsCGI")]
	public bool is_cgi();

	/**
	 * Initialize the FCGX library.
	 *
	 * Call in multi-threaded apps.
	 * @return 0 upon success.
	 */
	[CCode(cname = "FCGX_Init")]
	public int init();

	/**
	 * Create a FastCGI listen socket.
	 *
	 * @param path is the Unix domain socket (named pipe for WinNT), or a colon
	 * followed by a port number.  (e.g. "/tmp/fastcgi/mysocket", ":5000")
	 * @param backlog is the listen queue depth used in the listen() call.
	 * @return the socket's file descriptor or -1 on error.
	 */
	[CCode(cname = "FCGX_OpenSocket")]
	public int open_socket(string path, int backlog);

	/**
	 * Prevent the lib from accepting any new requests.
	 *
	 * Signal handler safe.
	 */
	[CCode(cname = "FCGX_ShutdownPending")]
	public void shutdown_pending();


	/**
	 * Accept a new request
	 *
	 * NOT thread-safe.
	 *
	 * Finishes the request accepted by (and frees any
	 * storage allocated by) the previous call.
	 * Creates input, output, and error streams and
	 * assigns them to in, out, and err respectively.
	 * Creates a parameters data structure and assigns it to envp.
	 *
	 * DO NOT retain pointers to the envp array or any strings
	 * contained in it, since these will be freed by
	 * the next call or a call to {@link finish}.
	 *
	 * @return 0 for successful call, -1 for error.
	 */
	[CCode(cname = "FCGX_Accept")]
	public int accept(out Stream @in, out Stream @out, out Stream err, out unowned parameters envp);

	/**
	 * Finish the current request
	 *
	 * NOT thread-safe.
	 *
	 * Finishes the request accepted by (and frees any
	 * storage allocated by) the previous call to {@link accept}.
	 *
	 * DO NOT retain pointers to the {@link parameters} or any strings
	 * contained in it, since these will be freed.
	 */
	[CCode(cname = "FCGX_Finish")]
	public void finish();

	[CCode(cname = "FCGI_stdin", cheader_filename = "fcgi_stdio.h")]
	public static FileStream stdin;
	[CCode(cname = "FCGI_stdout", cheader_filename = "fcgi_stdio.h")]
	public static FileStream stdout;
	[CCode(cname = "FCGI_stderr", cheader_filename = "fcgi_stdio.h")]
	public static FileStream stderr;

	/**
	 * FastCGI's abstraction over a file I/O
	 */
	[CCode(cname = "FCGI_FILE", cheader_filename = "fcgi_stdio.h", free_function = "FCGI_pclose")]
	public class FileStream {
		public GLib.FileStream file_stream {
			[CCode(cname = "FCGI_ToFILE")]
			get;
		}
		public Stream stream {
			[CCode(cname = "FCGI_ToFcgiStream")]
			get;
		}
		[CCode(cname = "FCGI_fflush")]
		public int flush();
		[CCode(cname = "FCGI_fseek")]
		public int seek (long offset, GLib.FileSeek whence);
		[CCode(cname = "FCGI_ftell")]
		public int tell();
		[CCode(cname = "FCGI_rewind")]
		public void rewind();
		[CCode(cname = "FCGI_fgetc")]
		public int getc();
		[CCode(cname = "FCGI_ungetc", instance_pos = -1)]
		public int ungetc(int c);
		[CCode(cname = "FCGI_fgets", instance_pos = -1)]
		public unowned string? gets (char[] s);
		[CCode (cname = "FCGI_fprintf")]
		[PrintfFormat ()]
		public void printf (string format, ...);
		[CCode (cname = "FCGI_vfprintf")]
		public void vprintf (string format, va_list args);
		[CCode (cname = "FCGI_fputc", instance_pos = -1)]
		public void putc (char c);
		[CCode (cname = "FCGI_fputs", instance_pos = -1)]
		public void puts (string s);
		[CCode (cname = "FCGI_fread", instance_pos = -1)]
		public size_t read ([CCode (array_length_pos = 2.1)] uint8[] buf, size_t size = 1);
		[CCode (cname = "FCGI_fwrite", instance_pos = -1)]
		public size_t write ([CCode (array_length_pos = 2.1)] uint8[] buf, size_t size = 1);
		[CCode (cname = "FCGI_feof")]
		public bool eof ();
		[CCode (cname = "FCGI_ferror")]
		public int error ();
		[CCode (cname = "FCGI_clearerr")]
		public void clearerr ();
		[CCode (cname = "FCGI_fileno")]
		public int fileno ();

		[CCode (cname = "FCGI_fopen")]
		public static FileStream? open (string path, string mode);
		[CCode (cname = "FCGI_fdopen")]
		public static FileStream? fdopen (int fildes, string mode);

		[CCode(cname = "FCGI_tmpfile")]
		public static FileStream? tmpfile();

		[CCode(cname = "FCGI_popen")]
		public static FileStream? popen(string cmd, string type);

		[DestroysInstance]
		[CCode(cname = "FCGI_freopen", instance_pos = -1)]
		public static FileStream? reopen(string path, string mode);
	}
}