abstract class Feature {

  void init() {
    places = new ArrayList<Destination>();
    switch(AGGREGATE_MODE) {
    case AGGREGATE_YEAR:
      init(true, false, false);
      break;
    case  AGGREGATE_MONTH:
      init(true, true, false);
      break;
    case  AGGREGATE_DAY:
      init(true, true, true);
      break;
    default:
      init(false, false, false);
      break;
    }
  }
  
  abstract void init(boolean byYear, boolean byMonth, boolean byDay);
  
  
}
