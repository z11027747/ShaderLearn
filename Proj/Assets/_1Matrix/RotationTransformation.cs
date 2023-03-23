using UnityEngine;

namespace _1Matrix
{
    public class RotationTransformation : Transformation
    {
        public Vector3 rotation;

        public override Matrix4x4 Matrix
        {
            get
            {
                var radX = rotation.x * Mathf.Deg2Rad;
                var radY = rotation.y * Mathf.Deg2Rad;
                var radZ = rotation.z * Mathf.Deg2Rad;

                var sinX = Mathf.Sin(radX);
                var cosX = Mathf.Cos(radX);
                var sinY = Mathf.Sin(radY);
                var cosY = Mathf.Cos(radY);
                var sinZ = Mathf.Sin(radZ);
                var cosZ = Mathf.Cos(radZ);

                var matrix = new Matrix4x4();
                matrix.SetRow(0, new Vector4()
                {
                    x = cosY * cosZ,
                    y = cosX * sinZ + sinX * sinY * cosZ,
                    z = sinX * sinZ - cosX * sinY * cosZ,
                    w = 0f,
                });
                matrix.SetRow(1, new Vector4()
                {
                    x = -cosY * sinZ,
                    y = cosX * cosZ + sinX * sinY * sinZ,
                    z = sinX * cosZ - cosX * sinY * sinZ,
                    w = 0f,
                });
                matrix.SetRow(2, new Vector4()
                {
                    x = sinY,
                    y = -sinX * cosY,
                    z = cosX * cosY,
                    w = 0f,
                });
                matrix.SetColumn(3, new Vector4(0f, 0f, 0f, 1f));
                return matrix;
            }
        }

        public override Vector3 Apply(Vector3 point)
        {
            var radX = rotation.x * Mathf.Deg2Rad;
            var radY = rotation.y * Mathf.Deg2Rad;
            var radZ = rotation.z * Mathf.Deg2Rad;

            var sinX = Mathf.Sin(radX);
            var cosX = Mathf.Cos(radX);
            var sinY = Mathf.Sin(radY);
            var cosY = Mathf.Cos(radY);
            var sinZ = Mathf.Sin(radZ);
            var cosZ = Mathf.Cos(radZ);

            var xAxis = new Vector3()
            {
                x = cosY * cosZ,
                y = cosX * sinZ + sinX * sinY * cosZ,
                z = sinX * sinZ - cosX * sinY * cosZ
            };

            var yAxis = new Vector3()
            {
                x = -cosY * sinZ,
                y = cosX * cosZ + sinX * sinY * sinZ,
                z = sinX * cosZ - cosX * sinY * sinZ
            };

            var zAxis = new Vector3()
            {
                x = sinY,
                y = -sinX * cosY,
                z = cosX * cosY
            };

            return xAxis * point.x + yAxis * point.y + zAxis * point.z;
        }
    }
}
