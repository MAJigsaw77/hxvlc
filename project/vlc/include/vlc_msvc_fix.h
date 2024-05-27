#ifndef VLC_MSVC_FIX_H
#define VLC_MSVC_FIX_H 1

#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

#include <vlc/vlc.h>

#endif // VLC_MSVC_FIX_H
