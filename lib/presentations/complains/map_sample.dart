import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/bloc/location_bloc/location_bloc.dart';
import '../../app/services/location_service.dart';

Widget _buildLocationWidget(BuildContext context, LocationLoaded state) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.location_pin, color: Colors.brown.shade400),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current location",
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87)),
                  Text(
                    state.address,
                    style: TextStyle(
                        fontSize: 14, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<LocationBloc>().add(FetchLocation());
              },
              child: Text("Change",
                  style: TextStyle(
                      color: Colors.brown.shade400,
                      fontWeight: FontWeight.w500)),
            )
          ],
        ),
      ),
      SizedBox(height: 20.h),
      SizedBox(
        height: 200,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                state.position.latitude,
                state.position.longitude,
              ),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(
                  state.position.latitude,
                  state.position.longitude,
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ),
      ),
    ],
  );
}

class MapSample extends StatelessWidget {
  const MapSample({super.key});

  @override
  Widget build(BuildContext context) {
    // Use LocationBloc from parent context (provided at app level)
    // If not available, create one as fallback
    try {
      // Try to access LocationBloc from parent
      final locationBloc = context.read<LocationBloc>();
      return BlocBuilder<LocationBloc, LocationState>(
        bloc: locationBloc,
        builder: (context, state) {
          // If state is initial, fetch location
          if (state is LocationInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              locationBloc.add(FetchLocation());
            });
          }
          
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocationLoaded) {
            return _buildLocationWidget(context, state);
          } else if (state is LocationError) {
            return Text('Error: ${state.message}');
          }
          return const SizedBox.shrink();
        },
      );
    } catch (e) {
      // LocationBloc doesn't exist in parent, create one
      return BlocProvider(
        create: (_) => LocationBloc(LocationService())..add(FetchLocation()),
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LocationLoaded) {
              return _buildLocationWidget(context, state);
            } else if (state is LocationError) {
              return Text('Error: ${state.message}');
            }
            return const SizedBox.shrink();
          },
        ),
      );
    }
  }
}
