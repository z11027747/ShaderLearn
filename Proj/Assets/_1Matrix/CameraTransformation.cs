using UnityEngine;

namespace _1Matrix
{
    public class CameraTransformation : Transformation
    {
        public float focalLength = 1f;
        
        public override Matrix4x4 Matrix
        {
            get
            {
                var matrix = new Matrix4x4();
                matrix.SetRow(0, new Vector4(focalLength, 0f, 0f, 0f));
                matrix.SetRow(1, new Vector4(0f, focalLength, 0f, 0f));
                matrix.SetRow(2, new Vector4(0f, 0f, 0f, 0f));
                matrix.SetRow(3, new Vector4(0f, 0f, 1f, 0f));
                return matrix;
            }
        }

        public override Vector3 Apply(Vector3 point)
        {
            throw new System.NotImplementedException();
        }
    }
}
