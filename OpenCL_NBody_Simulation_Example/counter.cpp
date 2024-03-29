//
// File:       counter.cpp
//
// Abstract:   This example performs an NBody simulation which calculates a gravity field 
//             and corresponding velocity and acceleration contributions accumulated 
//             by each body in the system from every other body.  This example
//             also shows how to mitigate computation between all available devices
//             including CPU and GPU devices, as well as a hybrid combination of both,
//             using separate threads for each simulator.
//
// Version:    <1.0>
//
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
//             in consideration of your agreement to the following terms, and your use,
//             installation, modification or redistribution of this Apple software
//             constitutes acceptance of these terms.  If you do not agree with these
//             terms, please do not use, install, modify or redistribute this Apple
//             software.
//
//             In consideration of your agreement to abide by the following terms, and
//             subject to these terms, Apple grants you a personal, non - exclusive
//             license, under Apple's copyrights in this original Apple software ( the
//             "Apple Software" ), to use, reproduce, modify and redistribute the Apple
//             Software, with or without modifications, in source and / or binary forms;
//             provided that if you redistribute the Apple Software in its entirety and
//             without modifications, you must retain this notice and the following text
//             and disclaimers in all such redistributions of the Apple Software. Neither
//             the name, trademarks, service marks or logos of Apple Inc. may be used to
//             endorse or promote products derived from the Apple Software without specific
//             prior written permission from Apple.  Except as expressly stated in this
//             notice, no other rights or licenses, express or implied, are granted by
//             Apple herein, including but not limited to any patent rights that may be
//             infringed by your derivative works or by other works in which the Apple
//             Software may be incorporated.
//
//             The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
//             WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
//             WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
//             PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
//             ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//             IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
//             CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//             SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//             INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//             AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
//             UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
//             OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright ( C ) 2008 Apple Inc. All Rights Reserved.
//

////////////////////////////////////////////////////////////////////////////////

#include <cstdlib>
#include <cmath>
#ifdef __EMSCRIPTEN__
#include <GL/gl.h>
#else
#include <OpenGL/OpenGL.h>
#endif
#include "graphics.h"
#include "counter.h"

#define MIN(a,b) (a<b?a:b)
#define DIGIT_WIDTH 35.0
#define TEXT_WIDTH 645.0

Counter::Counter(const char *rightText)
        : _x(0.0), _y(0.0), _w(0.0), _h(0.0), _number(0), _init(false)
{
    _rightText = strdup(rightText);
}

Counter::~Counter() {}

void Counter::setCounter(int number)
{
    _number = number;
}

void Counter::setX( float x )
{
    _x = x;
}
void Counter::setY( float y )
{
    _y = y;
}
void Counter::setW( float w )
{
    _w = w;
}
void Counter::setH( float h )
{
    _h = h;
}

void Counter::draw()
{
    if (!_init)
    {
        _init = true;
        char buffer[] = {0, 0};
        for ( int i = 0; i < 10; i++ )
        {
            buffer[0] = '0' + i;
            _digitTex[i] = CreateTextureWithLabelUseFont(buffer, 52.0, "Arial Bold", DIGIT_WIDTH, _h, 0 );
        }
        _rightTex = CreateTextureWithLabelUseFont( _rightText, 52.0, "Arial Bold", TEXT_WIDTH, _h, -1 );
    }
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _rightTex);
    float w0 = TEXT_WIDTH + 15 + 4 * (DIGIT_WIDTH - 3);
    float x0 = _x + (_w - w0) / 2.0;
    DrawQuadInverted( x0 + w0 - TEXT_WIDTH + 15, _y, TEXT_WIDTH, _h );

    int n = (int)lrint(floor(_number));
    int digitCount = 1;
    if (_number >= 1) digitCount += lrint(floor(log10(_number)));

    for (int i = 0; i < digitCount; i++ )
    {
        int r = n % 10;
        n /= 10;
        glBindTexture( GL_TEXTURE_2D, _digitTex[r] );
        DrawQuadInverted( x0 + w0 - TEXT_WIDTH - (i + 1)*(DIGIT_WIDTH - 3), _y, DIGIT_WIDTH, _h );
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);
}
