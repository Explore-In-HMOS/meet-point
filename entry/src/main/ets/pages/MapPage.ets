import { MapComponent, mapCommon, map, site, navi} from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import {Friend} from '../types/Friend';
import {getFriends} from '../utils/FriendUtils';
import {Location} from '../types/Location'

@Builder
export function MapPageBuilder() {
  MapPage()
}

@Component
struct MapPage {
  private TAG = 'HuaweiMapDemo';
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  @Consume pathStack: NavPathStack
  private friends: Friend[] = [];
  private selectedFriend: Friend | null = null;
  private currentLocation: geoLocationManager.Location | null = null;
  private locationRequest: geoLocationManager.LocationRequest = {
    priority: geoLocationManager.LocationRequestPriority.ACCURACY,
    timeInterval: 0,
    distanceInterval: 0,
    maxAccuracy: 0
  };
  private locationChangeCallback?: (location: geoLocationManager.Location) => void;

  private async loadFriends() {
    try {
      const friends = await getFriends();
      this.friends= friends;
      this.addFriendMarkers();
    } catch (error) {
      console.error('Failed to load friends:', error);
    }
  }

  aboutToAppear(): void {
    this.loadFriends();
    this.mapOptions = {
      position: {
        target: {
          latitude: 40.5352809,
          longitude: 34.9007045
        },
        zoom: 1
      }
    };

    this.locationChangeCallback = (location: geoLocationManager.Location) => {
      this.currentLocation = location;
      this.centerMapOnLocation(location);
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();
        this.mapController.setMyLocationEnabled(true);
        this.mapController.setMyLocationControlsEnabled(true);
        this.startLocationUpdates();

        let callback = () => {
          if (this.currentLocation) {
            this.centerMapOnLocation(this.currentLocation);
          }
          this.addFriendMarkers();
          this.setupMarkerClickEvents();
        }
        this.mapEventManager.on('mapLoad', callback);
      } else {
        console.error(`Failed to initialize the map. Code: ${err.code}; message: ${err.message}`);
      }
    };
  }

  private startLocationUpdates() {
    try {
      geoLocationManager.on('locationChange', this.locationRequest, this.locationChangeCallback!);
    } catch (error) {
      console.error('Location updates error:', error);
    }
  }
  private centerMapOnLocation(location: geoLocationManager.Location) {
    if (this.mapController) {
      const cameraPosition: mapCommon.CameraPosition = {
        target: {
          latitude: location.latitude,
          longitude: location.longitude
        },
        zoom: 1,
        tilt: 0,
        bearing: 0
      };

      let cameraUpdate = map.newCameraPosition(cameraPosition);
      this.mapController.animateCamera(cameraUpdate, 1000);
    }
  }
  private addFriendMarkers() {
    if (!this.mapController || this.friends.length === 0) {
      return;
    }

    this.friends.forEach((friend) => {
      if (friend.latitude && friend.longitude) {
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: friend.latitude,
            longitude: friend.longitude
          },
          title: friend.name,
          clickable: true,
          annotations: [{
            content: friend.name,
            fontStyle: 1,
            strokeWidth: 3,
            fontSize: 18
          }]
        };

       this.mapController!.addMarker(markerOptions);
      }
    });
  }

  private calculateMidpoint(lat1: number, lon1: number, lat2: number, lon2: number): Location {
    const lat1Rad = this.toRad(lat1);
    const lon1Rad = this.toRad(lon1);
    const lat2Rad = this.toRad(lat2);
    const lon2Rad = this.toRad(lon2);
    const x1 = Math.cos(lat1Rad) * Math.cos(lon1Rad);
    const y1 = Math.cos(lat1Rad) * Math.sin(lon1Rad);
    const z1 = Math.sin(lat1Rad);

    const x2 = Math.cos(lat2Rad) * Math.cos(lon2Rad);
    const y2 = Math.cos(lat2Rad) * Math.sin(lon2Rad);
    const z2 = Math.sin(lat2Rad);
    const x = (x1 + x2) / 2;
    const y = (y1 + y2) / 2;
    const z = (z1 + z2) / 2;
    const lon = Math.atan2(y, x);
    const lat = Math.atan2(z, Math.sqrt(x * x + y * y));
    const midLat = this.toDeg(lat);
    const midLon = this.toDeg(lon);

    return {
      latitude: midLat,
      longitude: midLon
    };
  }

  private toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  private toDeg(radians: number): number {
    return radians * (180 / Math.PI);
  }

  private setupMarkerClickEvents() {
    if (!this.mapEventManager) {
      return;
    }
    this.mapEventManager.on('markerClick', (marker) => {
      this.onMarkerClick(marker);
    });
  }

  private async onMarkerClick(marker: map.Marker) {
    const clickedFriend = this.friends.find(friend =>
    friend.latitude === marker.getPosition().latitude &&
      friend.longitude === marker.getPosition().longitude
    );

    if (clickedFriend && this.currentLocation) {
      this.selectedFriend = clickedFriend;
      const midPoint : Location = this.calculateMidpoint(
        this.currentLocation.latitude,
        this.currentLocation.longitude,
        clickedFriend.latitude,
        clickedFriend.longitude
      );

      const nearbySearchParams: site.NearbySearchParams = {
        location: midPoint,
        radius: 10000, // meters
        pageSize: 20,
        pageIndex: 1
      };
      const result = await site.nearbySearch(nearbySearchParams);
      const params: navi.DrivingRouteParams = {
        origins: [this.currentLocation],
        destination: {latitude: result.sites![0].location!.latitude, longitude: result.sites![0].location!.longitude},
        language: 'en'
      };

      const naviResult = await navi.getDrivingRoutes(params)
      const route = naviResult.routes[0];
      if (route.overviewPolyline) {
        const polyline: mapCommon.MapPolylineOptions = {
          points: route.overviewPolyline,
          width: 10,
          color: 0xFF0A84FF
        };
        const routeMarker : mapCommon.MarkerOptions = {
          position: {latitude: result.sites![0].location!.latitude, longitude: result.sites![0].location!.longitude},
          icon : $r('app.media.pinMapMarker')
        }
        await this.mapController!.addMarker(routeMarker);
        await this.mapController!.addPolyline(polyline);
      }
    }
  }

  aboutToDisappear(): void {
    if (this.locationChangeCallback) {
      geoLocationManager.off('locationChange', this.locationChangeCallback);
    }
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController.show();
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    NavDestination() {
      Stack() {
        MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback }).width('100%').height('100%');
      }.height('100%')
    }
    .hideTitleBar(true)
  }
}