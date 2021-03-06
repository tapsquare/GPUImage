#import "GPUImageStretchDistortionFilter.h"

NSString *const kGPUImageStretchDistortionFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp vec2 center;
 
 void main()
 {
     highp vec2 normCoord = 2.0 * textureCoordinate - 1.0;
     highp vec2 normCenter = 2.0 * center - 1.0;
     
     normCoord -= normCenter;
     mediump vec2 s = sign(normCoord);
     normCoord = abs(normCoord);
     normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
     normCoord = s * normCoord;
     
     normCoord += normCenter;
        
     mediump vec2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
     
     
     gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse );
     
 }
 );


@implementation GPUImageStretchDistortionFilter

@synthesize center = _center;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageStretchDistortionFragmentShaderString]))
    {
		return nil;
    }
    
    centerUniform = [filterProgram uniformIndex:@"center"];
    

   
    self.center = CGPointMake(0.5, 0.5);
    
    return self;
}

#pragma mark -
#pragma mark Accessors


- (void)setCenter:(CGPoint)newValue;
{
    _center = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    
    GLfloat centerPosition[2];
    centerPosition[0] = _center.x;
    centerPosition[1] = _center.y;
    
    glUniform2fv(centerUniform, 1, centerPosition);
}


@end
