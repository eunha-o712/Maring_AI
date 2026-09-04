package com.maring.api.safety;

/**
 * 위기 상담 자원. application.yml 의 maring.crisis-resources 에서 주입된다.
 * ⚠️ 번호·운영시간은 출시 전 최신 정보로 재확인할 것.
 */
public class CrisisResource {

    private String name;
    private String number;
    private String hours;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getHours() {
        return hours;
    }

    public void setHours(String hours) {
        this.hours = hours;
    }
}
