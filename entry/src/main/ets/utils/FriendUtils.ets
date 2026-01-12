
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';
import { Friend } from '../types/Friend';
import { Location } from '../types/Location';
import { GlobalRdbStore } from '../entryability/EntryAbility';

function generateTimestampCoordinates(): Location {
  const timestamp = new Date().getTime();
  const latSeed = (timestamp * 9301 + 49297) % 233280;
  const lonSeed = (timestamp * 49297 + 9301) % 233280;
  const minLat = 36.5;
  const maxLat = 41.5;
  const minLon = 26.0;
  const maxLon = 44.5;

  let latitude = minLat + (latSeed / 233280) * (maxLat - minLat);
  let longitude = minLon + (lonSeed / 233280) * (maxLon - minLon);
  const easternLimit = 27.5 + (latitude - minLat) * 3.5;
  if (longitude > easternLimit) {
    longitude = easternLimit;
  }

  return {
    latitude: parseFloat(latitude.toFixed(6)),
    longitude: parseFloat(longitude.toFixed(6))
  };
}

export async function addFriend(fullName: string): Promise<void> {
  try {
    const location: Location = generateTimestampCoordinates();

    let valueBucket: relationalStore.ValuesBucket = {
      'name': fullName,
      'latitude': location.latitude,
      'longitude': location.longitude
    };

    await GlobalRdbStore.rdbStore.insert('friends', valueBucket);
    promptAction.openToast({
      message: 'Friend added successfully',
      duration: 3000
    });

  } catch (error) {
    console.error('Unexpected error in addFriend:', error);
    promptAction.openToast({
      message: 'Unexpected error occurred while adding friend',
      duration: 3000
    });
  }
}

export async function getFriends(): Promise<Friend[]> {
  try {
    const predicates = new relationalStore.RdbPredicates('friends');
    const resultSet = await GlobalRdbStore.rdbStore.query(predicates, ['id', 'name', 'latitude', 'longitude']);

    if (!resultSet || resultSet.rowCount === 0) {
      return [];
    }

    const friendsList: Friend[] = [];
    while (resultSet.goToNextRow()) {
      try {
        const friend: Friend = {
          id: resultSet.getDouble(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')) || 'Unknown Name',
          latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
          longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude'))
        };
        friendsList.push(friend);
      } catch (itemError) {
        console.warn('Skipping invalid friend item:', itemError);
      }
    }

    resultSet.close();
    return friendsList;

  } catch (error) {
    console.error('Unexpected error in getFriends:', error);
    promptAction.openToast({
      message: 'Error getting friends: ' + (error as BusinessError).code,
      duration: 3000
    });
    return [];
  }
}

export async function deleteFriend(id: number): Promise<void> {
  try {
    const predicates = new relationalStore.RdbPredicates('friends');
    predicates.equalTo('id', id);

    const deletedRows = await GlobalRdbStore.rdbStore.delete(predicates);

    if (deletedRows > 0) {
      promptAction.openToast({
        message: 'Friend deleted successfully',
        duration: 3000
      });
    } else {
      promptAction.openToast({
        message: 'Friend not found in database',
        duration: 3000
      });
    }

  } catch (error) {
    console.error('Unexpected error in deleteFriend:', error);
    promptAction.openToast({
      message: 'Unexpected error occurred while deleting friend',
      duration: 3000
    });
  }
}

export async function updateFriend(id: number, fullName: string): Promise<void> {
  try {
    const predicates = new relationalStore.RdbPredicates('friends');
    predicates.equalTo('id', id);

    let valueBucket: relationalStore.ValuesBucket = {
      'name': fullName
    };

    const updatedRows = await GlobalRdbStore.rdbStore.update(valueBucket, predicates);

    if (updatedRows > 0) {
      promptAction.openToast({
        message: 'Friend updated successfully',
        duration: 3000
      });
    } else {
      promptAction.openToast({
        message: 'Friend not found in database',
        duration: 3000
      });
    }
  } catch (error) {
    console.error('Unexpected error in updateFriend:', error);
    promptAction.openToast({
      message: 'Unexpected error occurred while updating friend',
      duration: 3000
    });
  }
}