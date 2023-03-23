using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace _1Matrix
{

    public class TransformationGrid : MonoBehaviour
    {
        public Transform prefab;
        public int gridResolution = 10;

        private Transform[] _grid;
        private List<Transformation> _transformations;
        private Matrix4x4 _transformation;

        private void Awake()
        {
            _grid = new Transform[gridResolution * gridResolution * gridResolution];
            _transformations = new List<Transformation>();
            for (int i = 0, z = 0; z < gridResolution; z++)
            {
                for (var y = 0; y < gridResolution; y++)
                {
                    for (var x = 0; x < gridResolution; x++, i++)
                    {
                        _grid[i] = CreateGridPoint(x, y, z);
                    }
                }
            }
        }

        private Transform CreateGridPoint(int x, int y, int z)
        {
            var point = Instantiate(prefab, transform);
            point.localPosition = GetCoordinates(x, y, z);
            var meshRenderer = point.GetComponent<MeshRenderer>();
            meshRenderer.material.color = new Color()
            {
                r = (float)x / gridResolution,
                g = (float)y / gridResolution,
                b = (float)z / gridResolution,
            };
            return point;
        }

        private void Update()
        {
            UpdateTransformation();
            for (int i = 0, z = 0; z < gridResolution; z++)
            {
                for (var y = 0; y < gridResolution; y++)
                {
                    for (var x = 0; x < gridResolution; x++, i++)
                    {
                        _grid[i].localPosition = TransformPoint(x, y, z);
                    }
                }
            }
        }

        private void UpdateTransformation()
        {
            GetComponents<Transformation>(_transformations);
            if (_transformations.Count > 0)
            {
                _transformation = _transformations[0].Matrix;
                for (var i = 1; i < _transformations.Count; i++)
                {
                    _transformation = _transformations[i].Matrix * _transformation;
                }
            }
        }

        private Vector3 TransformPoint(int x, int y, int z)
        {
            var coordinates = GetCoordinates(x, y, z);
            return _transformation.MultiplyPoint(coordinates);
        }

        private Vector3 GetCoordinates(int x, int y, int z)
        {
            return new Vector3()
            {
                x = x - (gridResolution - 1) * 0.5f,
                y = y - (gridResolution - 1) * 0.5f,
                z = z - (gridResolution - 1) * 0.5f,
            };
        }
    }

}
