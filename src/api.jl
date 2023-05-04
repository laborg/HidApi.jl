"""
    hid_init()

Initialize the HIDAPI library.

This function initializes the HIDAPI library. Calling it is not	strictly necessary, as it will be called automatically by	hid\\_enumerate() and any of the hid\\_open\\_*() functions if it is	needed. This function should be called at the beginning of	execution however, if there is a chance of HIDAPI handles	being opened by different threads simultaneously.

` API`

### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(NULL) to get the failure reason.
"""
function hid_init()
    @ccall hidapi.hid_init()::Cint
end

"""
    hid_exit()

Finalize the HIDAPI library.

This function frees all of the static data associated with	HIDAPI. It should be called at the end of execution to avoid	memory leaks.

` API`

### Returns
This function returns 0 on success and -1 on error.
"""
function hid_exit()
    @ccall hidapi.hid_exit()::Cint
end

"""
    hid_enumerate(vendor_id, product_id)

Enumerate the HID Devices.

This function returns a linked list of all the HID devices	attached to the system which match vendor\\_id and product\\_id.	If `vendor_id` is set to 0 then any vendor matches.	If `product_id` is set to 0 then any product matches.	If `vendor_id` and `product_id` are both set to 0, then	all HID devices will be returned.

` API`

!!! note

    The returned value by this function must to be freed by calling hid\\_free\\_enumeration(),	when not needed anymore.

### Parameters
* `vendor_id`: The Vendor ID (VID) of the types of device	to open.
* `product_id`: The Product ID (PID) of the types of	device to open.
### Returns
This function returns a pointer to a linked list of type	struct #hid\\_device\\_info, containing information about the HID devices	attached to the system,	or NULL in the case of failure or if no HID devices present in the system.	Call hid\\_error(NULL) to get the failure reason.
"""
function hid_enumerate(vendor_id, product_id)
    @ccall hidapi.hid_enumerate(vendor_id::Cushort, product_id::Cushort)::Ptr{hid_device_info}
end

"""
    hid_free_enumeration(devs)

Free an enumeration Linked List

This function frees a linked list created by hid\\_enumerate().

` API`

### Parameters
* `devs`: Pointer to a list of struct\\_device returned from	hid\\_enumerate().
"""
function hid_free_enumeration(devs)
    @ccall hidapi.hid_free_enumeration(devs::Ptr{hid_device_info})::Cvoid
end

"""
    hid_open(vendor_id, product_id, serial_number)

Open a HID device using a Vendor ID (VID), Product ID	(PID) and optionally a serial number.

If `serial_number` is NULL, the first device with the	specified VID and PID is opened.

` API`

!!! note

    The returned object must be freed by calling hid\\_close(),	when not needed anymore.

### Parameters
* `vendor_id`: The Vendor ID (VID) of the device to open.
* `product_id`: The Product ID (PID) of the device to open.
* `serial_number`: The Serial Number of the device to open	(Optionally NULL).
### Returns
This function returns a pointer to a #hid\\_device object on	success or NULL on failure.	Call hid\\_error(NULL) to get the failure reason.
"""
function hid_open(vendor_id, product_id, serial_number)
    @ccall hidapi.hid_open(vendor_id::Cushort, product_id::Cushort, serial_number::Ptr{Cwchar_t})::Ptr{hid_device}
end

"""
    hid_open_path(path)

Open a HID device by its path name.

The path name be determined by calling hid\\_enumerate(), or a	platform-specific path name can be used (eg: /dev/hidraw0 on	Linux).

` API`

!!! note

    The returned object must be freed by calling hid\\_close(),	when not needed anymore.

### Parameters
* `path`: The path name of the device to open
### Returns
This function returns a pointer to a #hid\\_device object on	success or NULL on failure.	Call hid\\_error(NULL) to get the failure reason.
"""
function hid_open_path(path)
    @ccall hidapi.hid_open_path(path::Ptr{Cchar})::Ptr{hid_device}
end

"""
    hid_write(dev, data, length)

Write an Output report to a HID device.

The first byte of `data`[] must contain the Report ID. For	devices which only support a single report, this must be set	to 0x0. The remaining bytes contain the report data. Since	the Report ID is mandatory, calls to hid\\_write() will always	contain one more byte than the report contains. For example,	if a hid report is 16 bytes long, 17 bytes must be passed to	hid\\_write(), the Report ID (or 0x0, for devices with a	single report), followed by the report data (16 bytes). In	this example, the length passed in would be 17.

hid\\_write() will send the data on the first OUT endpoint, if	one exists. If it does not, it will send the data through	the Control Endpoint (Endpoint 0).

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: The data to send, including the report number as	the first byte.
* `length`: The length in bytes of the data to send.
### Returns
This function returns the actual number of bytes written and	-1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_write(dev, data, length)
    @ccall hidapi.hid_write(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t)::Cint
end

"""
    hid_read_timeout(dev, data, length, milliseconds)

Read an Input report from a HID device with timeout.

Input reports are returned	to the host through the INTERRUPT IN endpoint. The first byte will	contain the Report number if the device uses numbered reports.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: A buffer to put the read data into.
* `length`: The number of bytes to read. For devices with	multiple reports, make sure to read an extra byte for	the report number.
* `milliseconds`: timeout in milliseconds or -1 for blocking wait.
### Returns
This function returns the actual number of bytes read and	-1 on error.	Call hid\\_error(dev) to get the failure reason.	If no packet was available to be read within	the timeout period, this function returns 0.
"""
function hid_read_timeout(dev, data, length, milliseconds)
    @ccall hidapi.hid_read_timeout(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t, milliseconds::Cint)::Cint
end

"""
    hid_read(dev, data, length)

Read an Input report from a HID device.

Input reports are returned	to the host through the INTERRUPT IN endpoint. The first byte will	contain the Report number if the device uses numbered reports.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: A buffer to put the read data into.
* `length`: The number of bytes to read. For devices with	multiple reports, make sure to read an extra byte for	the report number.
### Returns
This function returns the actual number of bytes read and	-1 on error.	Call hid\\_error(dev) to get the failure reason.	If no packet was available to be read and	the handle is in non-blocking mode, this function returns 0.
"""
function hid_read(dev, data, length)
    @ccall hidapi.hid_read(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t)::Cint
end

"""
    hid_set_nonblocking(dev, nonblock)

Set the device handle to be non-blocking.

In non-blocking mode calls to hid\\_read() will return	immediately with a value of 0 if there is no data to be	read. In blocking mode, hid\\_read() will wait (block) until	there is data to read before returning.

Nonblocking can be turned on and off at any time.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `nonblock`: enable or not the nonblocking reads	- 1 to enable nonblocking	- 0 to disable nonblocking.
### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_set_nonblocking(dev, nonblock)
    @ccall hidapi.hid_set_nonblocking(dev::Ptr{hid_device}, nonblock::Cint)::Cint
end

"""
    hid_send_feature_report(dev, data, length)

Send a Feature report to the device.

Feature reports are sent over the Control endpoint as a	Set\\_Report transfer. The first byte of `data`[] must	contain the Report ID. For devices which only support a	single report, this must be set to 0x0. The remaining bytes	contain the report data. Since the Report ID is mandatory,	calls to hid\\_send\\_feature\\_report() will always contain one	more byte than the report contains. For example, if a hid	report is 16 bytes long, 17 bytes must be passed to	hid\\_send\\_feature\\_report(): the Report ID (or 0x0, for	devices which do not use numbered reports), followed by the	report data (16 bytes). In this example, the length passed	in would be 17.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: The data to send, including the report number as	the first byte.
* `length`: The length in bytes of the data to send, including	the report number.
### Returns
This function returns the actual number of bytes written and	-1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_send_feature_report(dev, data, length)
    @ccall hidapi.hid_send_feature_report(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t)::Cint
end

"""
    hid_get_feature_report(dev, data, length)

Get a feature report from a HID device.

Set the first byte of `data`[] to the Report ID of the	report to be read. Make sure to allow space for this	extra byte in `data`[]. Upon return, the first byte will	still contain the Report ID, and the report data will	start in data[1].

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: A buffer to put the read data into, including	the Report ID. Set the first byte of `data`[] to the	Report ID of the report to be read, or set it to zero	if your device does not use numbered reports.
* `length`: The number of bytes to read, including an	extra byte for the report ID. The buffer can be longer	than the actual report.
### Returns
This function returns the number of bytes read plus	one for the report ID (which is still in the first	byte), or -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_feature_report(dev, data, length)
    @ccall hidapi.hid_get_feature_report(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t)::Cint
end

"""
    hid_get_input_report(dev, data, length)

Get a input report from a HID device.

Since version 0.10.0, HID_API_VERSION >= HID\\_API\\_MAKE\\_VERSION(0, 10, 0)

Set the first byte of `data`[] to the Report ID of the	report to be read. Make sure to allow space for this	extra byte in `data`[]. Upon return, the first byte will	still contain the Report ID, and the report data will	start in data[1].

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `data`: A buffer to put the read data into, including	the Report ID. Set the first byte of `data`[] to the	Report ID of the report to be read, or set it to zero	if your device does not use numbered reports.
* `length`: The number of bytes to read, including an	extra byte for the report ID. The buffer can be longer	than the actual report.
### Returns
This function returns the number of bytes read plus	one for the report ID (which is still in the first	byte), or -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_input_report(dev, data, length)
    @ccall hidapi.hid_get_input_report(dev::Ptr{hid_device}, data::Ptr{Cuchar}, length::Csize_t)::Cint
end

"""
    hid_close(dev)

Close a HID device.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
"""
function hid_close(dev)
    @ccall hidapi.hid_close(dev::Ptr{hid_device})::Cvoid
end

"""
    hid_get_manufacturer_string(dev, string, maxlen)

Get The Manufacturer String from a HID device.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `string`: A wide string buffer to put the data into.
* `maxlen`: The length of the buffer in multiples of wchar\\_t.
### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_manufacturer_string(dev, string, maxlen)
    @ccall hidapi.hid_get_manufacturer_string(dev::Ptr{hid_device}, string::Ptr{Cwchar_t}, maxlen::Csize_t)::Cint
end

"""
    hid_get_product_string(dev, string, maxlen)

Get The Product String from a HID device.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `string`: A wide string buffer to put the data into.
* `maxlen`: The length of the buffer in multiples of wchar\\_t.
### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_product_string(dev, string, maxlen)
    @ccall hidapi.hid_get_product_string(dev::Ptr{hid_device}, string::Ptr{Cwchar_t}, maxlen::Csize_t)::Cint
end

"""
    hid_get_serial_number_string(dev, string, maxlen)

Get The Serial Number String from a HID device.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `string`: A wide string buffer to put the data into.
* `maxlen`: The length of the buffer in multiples of wchar\\_t.
### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_serial_number_string(dev, string, maxlen)
    @ccall hidapi.hid_get_serial_number_string(dev::Ptr{hid_device}, string::Ptr{Cwchar_t}, maxlen::Csize_t)::Cint
end

"""
    hid_get_device_info(dev)

Get The struct #hid\\_device\\_info from a HID device.

Since version 0.13.0, HID_API_VERSION >= HID\\_API\\_MAKE\\_VERSION(0, 13, 0)

` API`

!!! note

    The returned object is owned by the `dev`, and SHOULD NOT be freed by the user.

### Parameters
* `dev`: A device handle returned from hid\\_open().
### Returns
This function returns a pointer to the struct #hid\\_device\\_info	for this hid\\_device, or NULL in the case of failure.	Call hid\\_error(dev) to get the failure reason.	This struct is valid until the device is closed with hid\\_close().
"""
function hid_get_device_info(dev)
    @ccall hidapi.hid_get_device_info(dev::Ptr{hid_device})::Ptr{hid_device_info}
end

"""
    hid_get_indexed_string(dev, string_index, string, maxlen)

Get a string from a HID device, based on its string index.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open().
* `string_index`: The index of the string to get.
* `string`: A wide string buffer to put the data into.
* `maxlen`: The length of the buffer in multiples of wchar\\_t.
### Returns
This function returns 0 on success and -1 on error.	Call hid\\_error(dev) to get the failure reason.
"""
function hid_get_indexed_string(dev, string_index, string, maxlen)
    @ccall hidapi.hid_get_indexed_string(dev::Ptr{hid_device}, string_index::Cint, string::Ptr{Cwchar_t}, maxlen::Csize_t)::Cint
end

"""
    hid_error(dev)

Get a string describing the last error which occurred.

This function is intended for logging/debugging purposes.

This function guarantees to never return NULL.	If there was no error in the last function call -	the returned string clearly indicates that.

Any HIDAPI function that can explicitly indicate an execution failure	(e.g. by an error code, or by returning NULL) - may set the error string,	to be returned by this function.

Strings returned from hid\\_error() must not be freed by the user,	i.e. owned by HIDAPI library.	Device-specific error string may remain allocated at most until hid\\_close() is called.	Global error string may remain allocated at most until hid\\_exit() is called.

` API`

### Parameters
* `dev`: A device handle returned from hid\\_open(),	or NULL to get the last non-device-specific error	(e.g. for errors in hid\\_open() or hid\\_enumerate()).
### Returns
A string describing the last error (if any).
"""
function hid_error(dev)
    @ccall hidapi.hid_error(dev::Ptr{hid_device})::Ptr{Cwchar_t}
end

"""
    hid_version()

Get a runtime version of the library.

This function is thread-safe.

` API`

### Returns
Pointer to statically allocated struct, that contains version.
"""
function hid_version()
    @ccall hidapi.hid_version()::Ptr{hid_api_version}
end

"""
    hid_version_str()

Get a runtime version string of the library.

This function is thread-safe.

` API`

### Returns
Pointer to statically allocated string, that contains version string.
"""
function hid_version_str()
    @ccall hidapi.hid_version_str()::Ptr{Cchar}
end

