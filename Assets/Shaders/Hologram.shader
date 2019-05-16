
Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_ScanLineDist("ScanLinesDensity", float) = 100.0
		_LineMoveSpeed("LinesMoveSpeed", float) = 10.0
		_Bias("Bias", Range(-1, 1)) = 0
		_UseTexture("UseTexture", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100
		//ZWrite off
		Blend SrcAlpha OneMinusSrcAlpha
		//Blend SrcAlpha One
		Cull Off

		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 WorldVertPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _ScanLineDist;
			fixed4 _Color;
			float _LineMoveSpeed;
			float _Bias;
			float _UseTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.WorldVertPosition = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
				fixed4 col;
				if (_UseTexture == 0)
				{
					col = _Color * max(0 ,cos(i.WorldVertPosition.y * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
					col *= _Color * max(0, cos(i.WorldVertPosition.x * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
					col *= _Color * max(0, cos(i.WorldVertPosition.z * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
				}
				else
				{
					col = tex2D(_MainTex, i.uv) * max(0 ,cos(i.WorldVertPosition.y * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
					col *= tex2D(_MainTex, i.uv) * max(0, cos(i.WorldVertPosition.x * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
					col *= tex2D(_MainTex, i.uv) * max(0, cos(i.WorldVertPosition.z * _ScanLineDist + _Time.x * _LineMoveSpeed) + _Bias);
				}

				// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
